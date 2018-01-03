# File: ./strategy/secure/user_profile.rb
#
# ## Warden Interface
#
# - ClassMethods
# find_and_authenticate()
# fetch_remembered_user()
# fetch_cached_user()
#
# - Instance Methods
# logout()
# last_login_time_expired?()
# disable_authentication_controls()
# enable_authentication_controls()
#
# ##

require 'secure/user_profile_cache_provider'

class UserProfile
  include Secure::UserProfileCacheProvider

  attr_reader :login_after_seconds
  attr_accessor :last_access

  def initialize(user_hash)
    @attributes = user_hash
    @last_access = Time.now.getlocal
    @login_after_seconds = SknSettings.security.verify_login_after_seconds.to_i
  end

  # primary interface
  def attributes(attr, new_value=nil)
    new_value.nil? ? @attributes[attr.to_sym] : (@attributes[attr.to_sym] = new_value)
  end

  # Hash Notation
  def [](name)
    @attributes[name.to_sym]
  end
  def to_h
    @attributes.to_h
  end

  def active?
    @attributes[:active]
  end

  def self.authenticate(username, password)
     find_and_authenticate(username, password)
  end

  def self.find_and_authenticate(username, password)
    user = user_repo.find_by(username: username)
    if user && valid_digest?(user.password_digest, password)
      userp = self.new(user.to_h)
      debug_log "#{self.name}##{__method__}(success) Returns => #{userp.name}"
      userp
    else
      debug_log "#{self.name}##{__method__}(Failed) Returns => #{user&.name}"
      nil
    end
  end

  # Warden calls this
  def self.fetch_cached_user(id_value)
    userp = cache_provider_fetch_user(id_value.to_i)
    if userp && !userp.last_login_time_expired?
      userp.last_access = Time.now.getlocal
    else
      userp = nil  # force login as time has expired or cache was purged.
    end
    debug_log "#{self.name}##{__method__}() Returns => #{userp&.name}"

    userp
  end

  # Warden calls this
  def self.fetch_remembered_user (token=nil)
    return nil unless token.present?
    upp = nil
    value = user_repo.find_by(remember_token: token)
    upp = self.new(value.to_h) if value and valid_digest?(value.remember_token_digest, token)
    cache_provider_add_user(upp) if upp
    upp
  end

  # Warden calls this or any service
  def self.logout(id_num)
    return nil unless id_num.present?
    userp = cache_provider_fetch_user(id_num)
    userp.disable_authentication_controls if userp.present?
  end

  def last_login_time_expired?
    a = (Time.now.getlocal.to_i - last_access.to_i)
    time_is_up = (a > login_after_seconds )
    debug_log "#{self.name}##{__method__}() Returns => #{time_is_up}"
    time_is_up
  end


  # Warden will call this methods
  def disable_authentication_controls
    self.last_access = Time.now.getlocal
    cache_provider_delete_user(attributes(:id))
    attributes(:active, false)
    true
  end

  # Warden will call this methods
  def enable_authentication_controls
    attributes(:active, true)
    self.last_access = Time.now.getlocal
    cache_provider_add_user(self)
    true
  end

  # Warden will call this methods
  def self.security_session_time
    minutes_from_now(SknSettings.security.session_expires.to_i)
  end
  def self.security_remember_time
    minutes_from_now(SknSettings.security.remembered_for.to_i)
  end
  def self.minutes_from_now(val=20)
    # Time.now.advance(:minutes => val)
    TimeMath.min.advance(Time.now, val) # val.minutes.from_now
  end

  protected

  def self.user_repo
    Repositories::Users.new(SknSettings.rom)
  end

  def debug_log(msg)
    @debug_logger ||= (Logging.logger['UPR'] || ::SknSettings.logger.debug)
    @debug_logger.debug(msg)
  end

  def regenerate_remember_token!
    generate_unique_token(:remember_token)
    attributes(:remember_token_digest,
               get_new_secure_digest(attributes(:remember_token)))
  end

  def generate_unique_token(column)
    user_repository = user_repo
    begin
      if column.to_s.eql?("remember_token")
        attributes(column,  SecureRandom.urlsafe_base64)
      else
        attributes(column, generate_unique_key)
      end
    end while user_repository.find_by(column => attributes(column))
    true
  end

  # Returns true/false based on recorded digest matching unencrypted value
  def self.valid_digest?(digest, unencrypted)
    BCrypt::Password.new(digest).is_password?(unencrypted)
  end

  # returns true/false if any <column>_digest matches token
  # note: Password.new(digest) decrypts digest
  def token_authentic?(user, token)
    rcode = user.instance_variable_get(:@attributes).keys.each(&:to_s).select do |attr|
      attr.split("_").last.eql?("digest") ?
          BCrypt::Password.new(user[attr]).is_password?(token) : false
    end.any?    # any? returns true/false if any digest matched
    rcode
  end

  def generate_unique_key
    SecureRandom.hex(16)    # returns a 32 char string
  end

  def get_new_secure_digest(token)
    BCrypt::Password.create(token, cost: (BCrypt::Engine::MIN_COST + SknSettings.security.extra_digest_strength))
  end

  # Dot Notation
  def respond_to_missing?(method, _incl_private=false)
    @attributes.member?(method) || super
  end

  # Dot Notation
  def method_missing(method, *_args, &_block)
    if @attributes.member?(method)
      @attributes[method]
    elsif method.to_s[-1].eql?('?')
      @attributes.member?(method.to_s[0..-2].to_sym)
    else
      super
    end
  end

end
