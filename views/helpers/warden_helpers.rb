# File: views/helpers/warden_helpers.rb
#
module Skn
  class SknBase

    def remember_cookie_set
      if request.params["remember_me_token"].eql?("1")
        response.set_cookie('remember_token', { value: remember, expires: remembered_for , httponly: true })
      end
    end
    def remember_cookie_clear
      response.delete_cookie('remember_token')
    end

    def warden_messages
      flash_message(:info, warden.message) unless warden.message.nil?
      flash_message(:danger, warden.errors.full_messages) unless warden.errors.empty?
    end

    def valid_user?
      warden.authenticated?
    end

    def login_required?
      env['warden.options'] = {} unless env['warden.options']
      env['warden.options'][:attempted_path] = request.path
      return false if public_page?
      warden.authenticate!(message: 'Sign in Required!')
    end

    def redirect_to_origin
      if session[:return_to] && (session[:return_to].start_with?('/session') || session[:return_to].eql?('/new'))
        '/profiles/resources'
      else
        session[:return_to]
      end
    end

    def public_page?
      publics.any? {|p| p.start_with?(request.path) } || request.path.eql?('/')
    end
    def publics
      @publics ||= SknSettings.security.public_pages
    end

    # The main accessor for the warden proxy instance
    # :api: public
    def warden
      env['warden']
    end

    # Proxy to the authenticated? method on warden
    # :api: public
    def authenticated?(*args)
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

    def logout(*args)
      warden.raw_session.inspect  # Without this inspect here.  The session does not clear :|
      warden.logout(*args)
    end

    # Proxy to the authenticate method on warden
    # :api: public
    def authenticate(*args)
      warden.authenticate(*args)
    end

    # Proxy to the authenticate method on warden
    # :api: public
    def authenticate!(*args)
      defaults = {}
      if args.last.is_a? Hash
        args[-1] = defaults.merge(args.last)
      else
        args << defaults
      end
      warden.authenticate!(*args)
    end
  end
end