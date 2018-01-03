# File: ./strategy/secure/user_profile_cache.rb
#
# Add/Fetch/Delete UserProfile objects from ThreadSafe Cache
# Uses ThreadSafe::Hash from Concurrent-Ruby Gem
# Object are stored in Array with timestamp, fetch auto expires cache

# require 'concurrent'

module Secure
  class UserProfileCache
    include Singleton

    def initialize
      @_user_cache = Concurrent::Hash.new
      @_session_expires = SknSettings.security.session_expires
    end

    # Standard Interface
    def fetch(key)
      get(key)
    end

    def add(key, obj)
      put(key, obj)
      nil
    end

    def delete(key)
      remove(key)
    end

    def size
      @_user_cache.size
    end

    private

    def get(key)
      return nil if expired?(key)
      pkg = @_user_cache[key]
      pkg[1] = Time.now.getlocal
      pkg.first
    end

    def put(key, object)
      @_user_cache[key] = [object, Time.now.getlocal]
      nil
    end

    def expired?(key)
      pkg = @_user_cache[key]
      return true if pkg.nil?
      TimeMath.min.measure(pkg.last, Time.now.getlocal) > @_session_expires
    end

    def remove(key)
      @_user_cache.delete(key)
      nil
    end

  end
end