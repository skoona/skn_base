# config/warden.rb
# require 'warden'

# User Cache for serializers
# SknSettings.user_cache(user_id_number)

class Warden::SessionSerializer
  ##
  # Save the userProfile id to session store
  def serialize(record)
    [record.class.name, record.id]
  end

  ##
  # Restore a klass name and id from session store
  # Use id to find the existing object
  def deserialize(keys)
    # puts "===============[DEBUG]:sf #{self.class}\##{__method__}"
    klass, id = keys
    klass = case klass
              when Class
                klass
              when String, Symbol
                Object.const_get(klass.to_s)
            end
    klass.fetch_cached_user( id.to_i )
  end
end

# Todo: Create more of these specialty classes to wrap encodings
Warden::Strategies.add(:api_auth) do
  def auth
    @auth ||= Rack::Auth::Basic::Request.new(env)  # TODO: how long does this last, or for how many users?
  end

  def valid?
    rc = auth.provided? && auth.basic? && auth.credentials
    logger.debug " Warden::Strategies.add(:api_auth) [#{rc ? 'Selected' : 'Not Selected'}]"
    rc
  end

  def authenticate!
    user = UserProfile.find_and_authenticate(auth.credentials[0],auth.credentials[1])
   logger.debug " Warden::Strategies.add(:api_auth) User: [#{user&.name}]"
    (user and user.active) ? success!(user, "Signed in successfully.  Basic") : fail("Your Credentials are invalid or expired. Invalid username or password!  Fail Basic")
  rescue => e
    fail("Your Credentials are invalid or expired.  Not Authorized! [ApiAuth](#{e.message})")
  end
end

##
# Use the remember_token from the requests cookies to authorize user
Warden::Strategies.add(:remember_token) do
  def valid?
    rc = !request.cookies["remember_token"]
    logger.debug " Warden::Strategies.add(:remember_token) [#{rc ? 'Selected' : 'Not Selected'}]"
    rc
  end

  def authenticate!
    remember_token = request.cookies["remember_token"]
    token = Base64.decode64(remember_token.split('--').first)
    token = token[1..-2] if token[0] == '"'
    user = UserProfile.fetch_remembered_user(token)
   logger.debug " Warden::Strategies.add(:remember_token) User: [#{user&.name}]"
    (user and user.active?) ? success!(user, "Session successfully restored. Remembered!") : fail("Your session has expired. FailRemembered")
  rescue => e
    fail("Your Credentials are invalid or expired. Not Authorized! [RememberToken](#{e.message})")
  end
end

##
# Use the fields from the Signin page to authorize user
Warden::Strategies.add(:password) do
  def valid?
    if request.get?
      logger.debug " Warden::Strategies.add(:password) [Not Selected] -GET-"
      return false
    end
    rc = !params["sessions"]["username"].empty? && !params["sessions"]["password"].empty?
    logger.debug " Warden::Strategies.add(:password) [#{rc ? 'Selected' : 'Not Selected'}]"
    rc
  end

  def authenticate!
    user = UserProfile.find_and_authenticate(params["sessions"]["username"], params["sessions"]["password"])
   logger.debug " Warden::Strategies.add(:password) User: [#{user&.name}]"
    (user and user.active?) ? success!(user, "Signed in successfully. Password") : fail("Your Credentials are invalid or expired. Invalid username or password! FailPassword")
  rescue => e
    fail("Your Credentials are invalid or expired. [Password](#{e.message})")
  end
end

##
# This will always fail, and is used as the last option should prior options fail
Warden::Strategies.add(:not_authorized) do
  def valid?
    true
  end

  def authenticate!
   logger.debug " Warden::Strategies.add(:not_authorized) method: [#{request.request_method}]"
    fail!("Your Credentials are invalid or expired. Not Authorized! [NotAuthorized](FailNotAuthorized)")
  end
end

# ##
# A callback that runs on each request, just after the proxy is initialized
#
# Parameters:
# <block> A block to contain logic for the callback
#   Block Parameters: |proxy|
#     proxy - The warden proxy object for the request
# ##
Warden::Manager.on_request do |proxy|
  unless proxy.asset_request?
    proxy.logger.debug " Warden::Manager.on_request(public:#{proxy.public_page?}) PathInfo: #{proxy.env['PATH_INFO']}, AttemptedPage: #{proxy.request.session['skn.attempted.page']}, SessionID=#{proxy.request.session[:session_id]}, Method: #{proxy.env['REQUEST_METHOD']}"
  end
  true
end

##
# A callback that runs if no user could be fetched, meaning there is now no user logged in.
# - cleanup no-good cookies, and maybe session
# - All attempts to auth have been tried (i.e. all valid strategies)
#
Warden::Manager.after_failed_fetch do |user,auth,opts|
  unless auth.public_page?
    auth.logger.debug " Warden::Manager.after_failed_fetch(ONLY) PathInfo: #{auth.env['PATH_INFO']}, :remember_token present?(#{!auth.request.cookies["remember_token"].nil?}), opts=#{opts}, session_id=#{auth.request.session[:session_id]}"
  end
  true
end

##
# Injects the :new action on SessionsController
#
# A callback that runs just prior to the failure application being called.
# This callback occurs after PATH_INFO has been modified for the failure (default /unauthenticated)
# In this callback you can mutate the environment as required by the failure application
# If a Rails controller were used for the failure_app for example, you would need to set request[:params][:action] = :unauthenticated
# Ref: https://github.com/hassox/warden/blob/master/lib/warden/hooks.rb
#
# UnAuthenticated action is to allow another login attempt, thus we allow it to flow to failure_app of SessionsController#new
#
Warden::Manager.before_failure do |env, opts|
  these_cookies = opts[:roda_request] ? opts[:roda_request].cookies : env['warden'].request.cookies
  these_cookies.delete( 'remember_token')
  env['warden'].logger.debug " Warden::Manager.before_failure(ONLY) path:#{env['PATH_INFO']}, AttemptedPage: #{env['warden'].request.session['skn.attempted.page']}, session.id=#{env['warden'].request.session[:session_id]}"
  true
end

##
# Set remember_token only after a signin, and verify last login window
#
# A callback hook set to run every time after a user is set.
# This callback is triggered the first time one of those two events happens
# during a request: :authentication, and :set_user (when manually set).
#
# after_authentication is just a wrapper to after_set_user, which is only invoked
# when the user is set through the authentication path. The options and yielded arguments
# are the same as in after_set_user.
# -- after_authentication --
Warden::Manager.after_set_user except: :fetch do |user,auth,opts|
  remember = 'Some Kind of Value as Token'
  remember = user&.remember_token

  # setup user for session and object caching, and resolve authorization groups/roles
  user&.enable_authentication_controls

  domain_part = ("." + auth.env["SERVER_NAME"].split('.')[1..2].join('.')).downcase
  remembered_for = UserProfile.security_remember_time

  these_cookies = opts[:roda_request] ? opts[:roda_request].cookies : auth.cookies

  if remember
    if SknSettings.env.production?
      these_cookies['remember_token'] = { value: remember, domain: domain_part, expires: UserProfile.security_session_time, httponly: true, secure: true }
    else
      these_cookies['remember_token'] = { value: remember, domain: domain_part, expires: remembered_for , httponly: true }
    end
  else
    these_cookies.delete('remember_token')
  end

  if opts[:roda_request] and opts[:roda_request].respond_to?(:flash)
    opts[:roda_request].flash[:success] = opts[:message]
  end

  auth.logger.debug " Warden::Manager.after_set_user(#{user&.name}) AttemptedPage: #{auth.request.session['skn.attempted.page']}"
  true
end

##
# A callback that runs just prior to the logout of each scope.
# Logout the user object
Warden::Manager.before_logout do |user,auth,opts|
  these_cookies = opts[:roda_request] ? opts[:roda_request].cookies : auth.cookies
  user&.active = true
  user&.disable_authentication_controls
  these_cookies.delete( SknSettings.skn_base.session_key.to_s)
  auth.reset_session!
  auth.request.flash[:success] = opts[:message] if opts[:message]
  auth.logger.debug " Warden::Manager.before_logout(#{user&.name})"

  true
end

##
# Warden Overrides related to Roda environment.
module Warden
  class << self
    def asset_paths
      SknSettings.security.asset_paths
    end
  end
end

module Warden::Mixins::Common

  def cookies
    @cookies ||= request.cookies
  end

  def public_page?
    config[:public_pages].any? {|p| env['PATH_INFO'].start_with?(p) } || env['PATH_INFO'].eql?('/')
  end

  def logger
    unless defined?('SknSettings')
      puts 'logger not defined'
      return
    end
    @_warden_logger ||= (Logging.logger['WAR'] || ::SknSettings.logger.debug)
  end

  def reset_session!
    raw_session.inspect # why do I have to inspect it to get it to clear?
    raw_session.clear
  end

end # end common
