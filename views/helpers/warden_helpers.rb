# File: views/helpers/warden_helpers.rb
#
module Skn
  class SknBase

    def login_required?
      session['skn.attempted.page'] = request.path
      return false if public_page?
      warden.authenticate!(message: 'Sign in Required!')
    end

    def warden_messages
      flash_message(:info, warden.message) unless warden.message.nil?
      flash_message(:danger, warden.errors.full_messages) unless warden.errors.empty?
    end

    def valid_user?
      link_warden
      warden.authenticated?
    end

    def redirect_to_origin
      orig = session['skn.attempted.page']
      if orig.nil? || orig.empty? || orig.start_with?('/session') || orig.eql?('/new')
        orig = '/profiles/resources'
      end
      SknSettings.logger.debug "#{self.class}##{__method__}() Returns: [#{orig}]"
      orig
    end

    def public_page?
      publics.any? {|p| p.start_with?(request.path) } || request.path.eql?('/')
    end
    def publics
      @_publics ||= SknSettings.security.public_pages
    end

    # The main accessor for the warden proxy instance
    # :api: public
    def warden
      env['warden']
    end

    # Proxy to the authenticated? method on warden
    # :api: public
    def authenticated?(*args)
      link_warden
      warden.authenticated?(*args)
    end
    alias_method :logged_in?, :authenticated?

    # Access the currently logged in user
    # :api: public
    def user(*args)
      warden.user(*args)
    end
    alias_method :current_user, :user

    def user=(user)
      warden.set_user user
    end
    alias_method :current_user=, :user=

    def logout(*list_of_scopes)
      link_warden
      warden.raw_session.inspect  # Without this inspect here.  The session does not clear :|
      warden.logout(*list_of_scopes)
    end

    # Proxy to the authenticate method on warden
    # :api: public
    def authenticate!(*args)
      defaults = {roda_request: request}
      if args.last.is_a? Hash
        args[-1] = defaults.merge(args.last)
      else
        args << defaults
      end
      warden.authenticate!(*args)
    end

    # If our copy of env is different from warden's copy, this serves no purpose
    # however, warden api's which take options do work in this fashion
    def link_warden
      env['warden.options'] = {} if env['warden.options'].nil?
      env['warden.options'].merge!({roda_request: request})
    end
  end
end