# File: ./main/skn_base.rb
# Desc: Main Application entry point

require_relative "boot"

module Skn
  class SknBase < Roda

    use Rack::CommonLogger, Logging.logger['WEB']
    use Rack::Session::Cookie, {
          secret: SknSettings.skn_base.secret,
          key: SknSettings.skn_base.session_key,
          domain: SknSettings.skn_base.session_domain,
          expires:UserProfile.security_session_time
    }
    use Rack::Cookies
    use Rack::Protection
    use Rack::MethodOverride

    use Rack::Reloader  if SknSettings.env.development?
    use Rack::ShowExceptions

    use Warden::Manager do |manager|
      manager.default_scope = :access_profile
      manager.default_strategies :api_auth, :remember_token, :password, :not_authorized
      manager.scope_defaults :access_profile, {
                             store: true,
                             strategies: [:api_auth, :password, :remember_token, :not_authorized],
                             action: '/sessions/unauthenticated' }
      manager.failure_app = self
      manager[:roda_class] = self
    end

    plugin :all_verbs
    plugin :symbol_views
    plugin :view_options
    plugin :content_for
    plugin :head
    plugin :csrf, raise: true, skip_if: lambda { |request|
      ['HTTP_AUTHORIZATION', 'X-HTTP_AUTHORIZATION',
       'X_HTTP_AUTHORIZATION', 'REDIRECT_X_HTTP_AUTHORIZATION'].any? {|k| request.env.key?(k) }
    }
    plugin :flash
    plugin :render, {
        engine: 'html.erb',
        allowed_paths: ['views', 'views/layouts', 'views/profiles', 'views/sessions'],
        layout: '/application',
        layout_opts: {views: 'views/layouts'}
    }
    plugin :static, %w[/images /fonts]
    plugin :multi_route
    plugin :assets, {
           css_dir: 'stylesheets',
           js_dir: 'javascript',
           css: ['skn_base.css.scss' ] ,
           js: ['jquery-3.2.1.js', 'bootstrap-3.3.7.js', 'jquery.matchHeight.js', 'bootstrap-select.js',
                'jquery.dataTables.js', 'dataTables.bootstrap.js', 'skn-base.custom.js'],
           dependencies: {'_bootstrap.scss' => Dir['assets/stylesheets/**/*.scss', 'assets/stylesheets/*.scss'] }
    }
    plugin :not_found do
       view :http_404, path: File.expand_path('../views/http_404.html.erb', __dir__)
    end
    plugin :error_handler do |uncaught_exception|
      # response.status = 404
      view :unknown, locals: {exception: uncaught_exception }, path: File.expand_path('../views/unknown.html.erb', __dir__)
    end
    plugin :cookies, domain: SknSettings.skn_base.session_domain, path: '/'

    opts[:root] = Pathname(__FILE__).join("..").realpath.dirname.freeze

    # ##
    # Routing Table
    # ##
    route do |r|

      r.assets unless SknSettings.env.production?

      SknSettings.logger.debug "DEBUG: MAIN-ROUTE PASSING => #{request.path}, OPTS => #{opts[:root]}, REQUEST-METHOD => #{request.request_method}"

      r.multi_route

      r.root do
        # binding.pry

        view(:homepage)
      end

      r.get "about" do
        view(:about)
      end

      r.get "contact" do
        view(:contact)
      end

    end

  end
end

# Named Routes
Dir['./routes/*.rb'].each{|f| require f }

# view helpers
Dir['./views/helpers/*.rb'].each{|f| require f }

# ##
#
# Load Business Logic after this mark.
# - Loadpath has been established and all gems have been required.
#
# ##

