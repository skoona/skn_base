# config/warden.rb
# require 'warden'

# User Cache
# SknSettings.users session['session_id']

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
    auth.provided? && auth.basic? && auth.credentials
  end

  def authenticate!
    user = UserProfile.find_and_authenticate(auth.credentials[0],auth.credentials[1])
   env['warden'].logger.debug " Warden::Strategies.add(:api_auth) User: [#{user&.name}]"
    (user and user.active) ? success!(user, "Signed in successfully.  Basic") : fail("Your Credentials are invalid or expired. Invalid username or password!  Fail Basic")
  rescue => e
    fail("Your Credentials are invalid or expired.  Not Authorized! [ApiAuth](#{e.message})")
  end
end

##
# Use the remember_token from the requests cookies to authorize user
Warden::Strategies.add(:remember_token) do
  def valid?
    !request.cookies["remember_token"]
  end

  def authenticate!
    remember_token = request.cookies["remember_token"]
    token = Base64.decode64(remember_token.split('--').first)
    token = token[1..-2] if token[0] == '"'
    user = UserProfile.fetch_remembered_user(token)
   env['warden'].logger.debug " Warden::Strategies.add(:remember_token) User: [#{user&.name}]"
    (user and user.active?) ? success!(user, "Session successfully restored. Remembered!") : fail("Your session has expired. FailRemembered")
  rescue => e
    fail("Your Credentials are invalid or expired. Not Authorized! [RememberToken](#{e.message})")
  end
end

##
# Use the fields from the Signin page to authorize user
Warden::Strategies.add(:password) do
  def valid?
    return false if request.get?
    !params["sessions"]["username"].empty? and !params["sessions"]["password"].empty?
  end

  def authenticate!
    user = UserProfile.find_and_authenticate(params["sessions"]["username"], params["sessions"]["password"])
   env['warden'].logger.debug " Warden::Strategies.add(:password) User: [#{user&.name}]"
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
   env['warden'].logger.debug " Warden::Strategies.add(:not_authorized) User: [#{user&.name}]"
    fail!("Your Credentials are invalid or expired. Not Authorized! [NotAuthorized](FailNotAuthorized)")
  end
end

##
# A callback that runs if no user could be fetched, meaning there is now no user logged in.
# - cleanup no-good cookies, and maybe session
# - All attempts to auth have been tried (i.e. all valid strategies)
#
Warden::Manager.after_failed_fetch do |user,auth,opts|
  auth.logger.debug " Warden::Manager.after_failed_fetch(ONLY) :remember_token present?(#{!auth.request.cookies["remember_token"].nil?}), opts=#{opts}, session.id=#{auth.request.session[:session_id]}"
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
  env['warden'].request.cookies.delete( 'remember_token')
  env['warden'].request.cookies.delete( SknSettings.skn_base.session_key.to_s)
  env['warden'].reset_session!
  env['warden'].logger.debug " Warden::Manager.before_failure(ONLY) path:#{env['PATH_INFO']}, session.id=#{env['warden'].request.session[:session_id]}"
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
  remember = false
  remember = user&.remember_token

  # setup user for session and object caching, and resolve authorization groups/roles
  user&.enable_authentication_controls

  domain_part = ("." + auth.env["SERVER_NAME"].split('.')[1..2].join('.')).downcase
  remembered_for = UserProfile.security_remember_time

  if remember
    if SknSettings.env.production?
      auth.request.cookies['remember_token'] = { value: remember, domain: domain_part, expires: UserProfile.security_session_time, httponly: true, secure: true }
    else
      auth.request.cookies['remember_token'] = { value: remember, domain: domain_part, expires: remembered_for , httponly: true }
    end
  else
    auth.request.cookies.delete('remember_token')
  end
  auth.logger.debug " Warden::Manager.after_set_user(#{user&.name})"
  true
end

##
# A callback that runs just prior to the logout of each scope.
# Logout the user object
Warden::Manager.before_logout do |user,auth,opts|
  user&.active = true
  user&.disable_authentication_controls
  auth.request.cookies.delete( SknSettings.skn_base.session_key.to_s)
  auth.reset_session!
  auth.request.flash[:notice] = opts[:message] if opts[:message]
  auth.logger.debug " Warden::Manager.before_logout(#{user&.name})"

  true
end

##
# Warden Overrides related to Roda environment.

module Warden::Mixins::Common

  # def cookies
  #   unless defined?('ActionController::Cookies')
  #     puts 'cookies was not defined'
  #     return
  #   end
  #   @cookies ||= begin
  #                  # Duck typing...
  #     controller = Struct.new(:request, :response) do
  #       def self.helper_method(*args); end
  #     end
  #     controller.send(:include, ActionController::Cookies)
  #     controller.new(self.request, self.response).send(:cookies)
  #   end
  # end

  def logger
    unless defined?('SknSettings')
      puts 'logger not defined'
      return
    end
    SknSettings.logger
  end

  def reset_session!
    raw_session.inspect # why do I have to inspect it to get it to clear?
    raw_session.clear
  end

end # end common
