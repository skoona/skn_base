# File: ./strategy/secure/user_profile_cache_provider.rb
#
# Interface to UserProfileCache, assume auto expiration of cached items

module Secure
  module UserProfileCacheProvider

    def self.included(klass)
      klass.extend CacheClassMethods
    end

    module CacheClassMethods
      # UserProfile Interface
      def cache_provider_fetch_user(id_num)
        userp = user_profile_cache_provider.fetch(id_num.to_i)
        debug_log "#{self.name}##{__method__}() Acted on: #{userp.respond_to?(:name) ? userp&.name : userp}"
        userp
      end

      def cache_provider_add_user(userp)
        return false if userp.nil? || !userp.respond_to?(:id)
        user_profile_cache_provider.add(userp.id, userp)
        debug_log "#{self.name}##{__method__}() Acted on: #{userp&.name}"
        nil
      end

      def cache_provider_delete_user(userp)
        return false if userp.nil?
        uid = userp.respond_to?(:id) ? userp.id : userp
        user_profile_cache_provider.delete(uid)
        debug_log "#{self.name}##{__method__}() Acted on: #{userp.respond_to?(:name) ? userp.name : userp}"
        nil
      end

      protected

      def debug_log(msg)
        @_debug_logger ||= (Logging.logger['UPR'] || ::SknSettings.logger.debug)
        @_debug_logger.debug(msg)
      end

      private

      def user_profile_cache_provider
        ::Secure::UserProfileCache.instance
      end
    end

    # UserProfile Interface
    def cache_provider_fetch_user(id_num)
      self.class.cache_provider_fetch_user(id_num)
    end

    def cache_provider_add_user(userp)
      self.class.cache_provider_add_user(userp)
    end

    def cache_provider_delete_user(userp)
      self.class.cache_provider_delete_user(userp)
    end

  end
end