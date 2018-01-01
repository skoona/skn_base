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
    (user and user.active) ? success!(user, "Signed in successfully.  Basic") : fail("Your Credentials are invalid or expired. Invalid username or password!  Fail Basic")
  rescue => e
    fail("Your Credentials are invalid or expired.  Not Authorized! [ApiAuth](#{e.message})")
  end
end

##
# Use the remember_token from the requests cookies to authorize user
Warden::Strategies.add(:remember_token) do
  def valid?
    !request.cookies["remember_token"].empty?
  end

  def authenticate!
    remember_token = request.cookies["remember_token"]
    token = Base64.decode64(remember_token.split('--').first)
    token = token[1..-2] if token[0] == '"'
    user = UserProfile.fetch_remembered_user(token)
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
    (user and user.active?) ? success!(user, "Signed in successfully. Password") : fail!("Your Credentials are invalid or expired. Invalid username or password! FailPassword")
  rescue => e
    fail!("Your Credentials are invalid or expired. [Password](#{e.message})")
  end
end

##
# This will always fail, and is used as the last option should prior options fail
Warden::Strategies.add(:not_authorized) do
  def valid?
    true
  end

  def authenticate!
    fail!("Your Credentials are invalid or expired. Not Authorized! [NotAuthorized](FailNotAuthorized)")
  end
end

##
# A callback that runs just prior to the logout of each scope.
# Logout the user object
Warden::Manager.before_logout do |user,auth,opts|
  user.active = true if user
  session_id_before_reset = auth.request.session_options[:id]
  domain_part = ("." + auth.env["SERVER_NAME"].split('.')[1..2].join('.')).downcase
  user.disable_authentication_controls unless user.nil?
  auth.cookies.delete( SknSettings.skn_base.secret, domain: domain_part )
  auth.request.reset_session
  auth.request.flash[:notice] = opts[:message] if opts[:message]

  true
end
