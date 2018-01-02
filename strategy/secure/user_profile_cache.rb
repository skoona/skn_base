# File: ./strategy/secure/user_profile_cache.rb
#
# Add/Fetch/Delete UserProfile objects from ThreadSafe Cache

module Secure
  class UserProfileCache

    def self.call(id_num, opts={})
      self.new(opts).call(id_num)
    end

    def initialize(opts={})
      @cache = opts.fetch(:backend, SknSettings.security.user_cache)
      @logger = opts.fetch(:logger, SknSettings.logger)
    end

    def fetch(id_num)
      userp = user_cache[id_num]
      @logger.debug "#{self.class.name}##{__method__}() Acted on: #{userp.respond_to?(:name) ? userp&.name : userp}"
      userp
    end
    alias_method :fetch_cached_user, :fetch
    alias_method :call, :fetch

    def add(userp)
      return false if userp.nil? || !userp.respond_to?(:id)
      user_cache[userp.id] = userp
      @logger.debug "#{self.class.name}##{__method__}() Acted on: #{userp&.name}"
      true
    end

    def delete(userp)
      return false if userp.nil?
      uid = userp.respond_to?(:id) ? userp.id : userp
      user_cache.delete(uid)
      @logger.debug "#{self.class.name}##{__method__}() Acted on: #{userp&.name}"
      true
    end

    def size
      sz = user_cache.size
      @logger.debug "#{self.class.name}##{__method__}() returned: #{sz}"
      sz
    end

    private

    def user_cache
      @cache
    end
  end
end