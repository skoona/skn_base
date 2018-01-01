# File: views/helpers/base_helpers.rb
#
module Skn
  class SknBase
    def menu_active?(item_path)
      request.path.eql?(item_path) ? 'active' : ''
    end

    def current_user
      warden.user
    end
    def valid_user?
      warden.authenticated?
    end
    alias_method :authenticated?, :valid_user?

    def login_required?(router)
      return false if public_page?
      rc = false
      unless warden.authenticated?
        flash[:notice] = 'Sign in required!'
        rc = true
        force_authentication(router)
      end
      rc
    end

    def force_authentication(router)
      session[:return_to] = request.fullpath
      router.redirect('/sessions/signin')
      # binding.pry
    end

    def redirect_to_origin
      if session[:return_to] && session[:return_to].start_with?('/session') || session[:return_to].eql?('/new')
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

    def warden
      env['warden']
    end

  end
end