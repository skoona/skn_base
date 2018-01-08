# config/warden.rb
# require 'warden'


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
    rc = !!cookies["remember_token"]
    logger.debug " Warden::Strategies.add(:remember_token) [#{rc ? 'Selected' : 'Not Selected'}]"
    rc
  end

  def authenticate!
    user = UserProfile.fetch_remembered_user(cookies["remember_token"])
    logger.debug " Warden::Strategies.add(:remember_token) User: [#{user&.name}]"
      (user and user.active?) ? success!(user, "Session successfully restored. Remembered!") : fail!("Your session has expired. FailRemembered")
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
      (user and user.active?) ? success!(user, "Signed in successfully. Password") : fail!("Your Credentials are invalid or expired. Invalid username or password! FailPassword")
  rescue => e
    fail("Your Credentials are invalid or expired. [Password](#{e.message})")
  end
end

##
# This will always fail, and is used as the last option should prior options fail
Warden::Strategies.add(:not_authenticated) do
  def valid?
    true
  end

  def authenticate!
   logger.debug " Warden::Strategies.add(:not_authenticated) method: [#{request.request_method}]"
    fail!("Authentication is Required to access this page!  Please Sign in.  [NotAuthenticated](FailNotAuthorized)")
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
  unless proxy.public_page?
    proxy.logger.debug " Warden::Manager.on_request(ENTER) userId=#{proxy.user().name if proxy.authenticated?}, token=#{!proxy.cookies['remember_token'].nil?}, path_info=#{proxy.env['PATH_INFO']}, session.keys=#{proxy.raw_session.keys}"

    # If session has expired logout the user, unless remember cookie is still valid
    # Browser deletes cookies that have expired so remembered should be nil or false
    # #fetch cached user will make it inactive if login timer expires
    if proxy.authenticated? && !proxy.user.active?
      proxy.logger.debug " Warden::Manager.on_request(Logout: Session Expired) User => [#{usr.name}]"
      proxy.errors.add(:general, "Your Session has Expired! [Warden](#on_request)")
      proxy.logout
    end

    # see if we can restore a session via API or RememberToken
    unless proxy.authenticated?
      proxy.logger.debug " Warden::Manager.on_request(Attempt Remembered)"
      proxy.authenticate(:api_auth, :remember_token)
    end
    proxy.logger.debug " Warden::Manager.on_request(EXIT) PathInfo: #{proxy.env['PATH_INFO']}, AttemptedPage: #{proxy.request.session['skn.attempted.page']}, SessionID=#{proxy.request.session[:session_id]}, Method: #{proxy.env['REQUEST_METHOD']}"
  end

  true
end

# ##
# A callback that runs if no user could be fetched, meaning there is now no user logged in.
# - All attempts to auth have been tried (i.e. all valid strategies)
# ##
Warden::Manager.after_failed_fetch do |user,auth,opts|
  unless auth.public_page?
    auth.logger.debug " Warden::Manager.after_failed_fetch(ONLY) PathInfo: #{auth.env['PATH_INFO']}, :remember_token present?(#{!!auth.cookies["remember_token"]}), opts=#{opts}, session_id=#{auth.raw_session[:session_id]}"
  end
  true
end

# ##
#
# A callback that runs just prior to the failure application being called.
# This callback occurs after PATH_INFO has been modified for the failure (default /sessions/unauthenticated)
# In this callback you can mutate the environment as required by the failure application
# Ref: https://github.com/hassox/warden/blob/master/lib/warden/hooks.rb
#
# UnAuthenticated action may allow another login attempt via a UI, thus we allow it to flow to failure_app
# ##
Warden::Manager.before_failure do |env, opts|
  env['warden'].cookies.delete( 'remember_token')
  env['warden'].flash_message(:info, env['warden'].message) if env['warden'].message
  env['warden'].flash_message(:danger, env['warden'].errors.full_messages) unless env['warden'].errors.empty?
  env['warden'].logger.debug " Warden::Manager.before_failure(#{env['warden'].request.object_id}) path:#{env['PATH_INFO']}, AttemptedPage: #{env['warden'].request.session['skn.attempted.page']}, session.id=#{env['warden'].request.session[:session_id]}, Msg: #{env['warden'].message}"
  true
end

# ##
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
# ##
Warden::Manager.after_set_user except: :fetch do |user,auth,opts|
  remember = false
  remember = user&.remember_token  if auth.cookies['remember_token'] || '1'.eql?(auth.params.dig('sessions', 'remember_me_token'))

  # setup user for session and object caching, and resolve authorization groups/roles
  user&.enable_authentication_controls

  domain_part = ("." + auth.env["SERVER_NAME"].split('.')[1..2].join('.')).downcase
  remembered_for = auth.security_remember_time
  sessions_last = auth.security_session_time

  if remember
    if auth.config[:production]
      auth.cookies['remember_token'] = { value: remember, domain: domain_part, expires: sessions_last, httponly: true, secure: true }
    else
      auth.cookies['remember_token'] = { value: remember, domain: domain_part, expires: remembered_for , httponly: true }
    end
  else
    auth.cookies.delete('remember_token')
  end

  auth.flash_message(:info, auth.message) if auth.message

  auth.logger.debug " Warden::Manager.after_set_user(#{user&.name}) AttemptedPage: #{auth.request.session['skn.attempted.page']}"
  true
end

##
# A callback that runs just prior to the logout of each scope.
# Logout the user object
Warden::Manager.before_logout do |user,auth,opts|
  user&.active = true
  user&.disable_authentication_controls
  msg = auth.message
  auth.reset_session!
  auth.flash_message(:success, msg) if msg
  auth.logger.debug " Warden::Manager.before_logout(#{user&.name}) Msg: #{msg}"
  true
end

##
# Warden Overrides related to Roda environment.
module Warden
  class << self
    def asset_paths
      config[:asset_paths_ary]
    end
  end
end

module Warden::Mixins::Common

  def flash_message(rtype, text)
    return nil if request.session[:_flash].nil?

    flash = request.session[:_flash]

    type = [:success, :info, :warning, :danger].include?(rtype.to_sym) ? rtype.to_sym : :info
    if flash[type] and flash[type].is_a?(Array)
      flash[type].push(text)
    elsif flash[type] and flash[type].is_a?(String)
      flash[type] = [flash[type], text]
    else
      flash[type] = text
    end
  end

  def cookies
    env['rack.cookies'] # request.cookies
  end

  def public_page?
    ((config[:public_pages].any? {|p| env['PATH_INFO'].start_with?(p) }) || (env['PATH_INFO'].eql?('/')))
  end

  def logger
    @_sys_logger ||= config[:sys_logger] rescue Logging.logger['WAR']
  end

  def reset_session!
    raw_session.inspect # why do I have to inspect it to get it to clear?
    raw_session.clear
  end

  # Warden will call this methods
  def security_session_time
    minutes_from_now(config[:session_expires])
  end
  def security_remember_time
    minutes_from_now(config[:remember_for])
  end
  def minutes_from_now(val=20)
    TimeMath.min.advance(Time.now.getlocal, val) # val.minutes.from_now
  rescue => e
      logger.error " Warden::Mixins::Common.minutes_from_now() calculator Failed: #{e.message}"
      60
  end


end # end common
