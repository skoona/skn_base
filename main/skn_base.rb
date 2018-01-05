# File: ./main/skn_base.rb
# Desc: Main Application entry point

require_relative "boot"

module Skn
  class SknBase < Roda

    opts[:root] = Pathname(__FILE__).join("..").realpath.dirname.freeze

    use Rack::CommonLogger, Logging.logger['WEB']

    use Rack::Cookies
    use Rack::Session::Cookie, {
        secret: SknSettings.skn_base.secret,
        key: SknSettings.skn_base.session_key,
        domain: SknSettings.skn_base.session_domain
    }
    use Rack::Protection
    use Rack::MethodOverride

    use Rack::Reloader  if SknSettings.env.development?
    use Rack::ShowExceptions
    use Rack::NestedParams

    plugin :all_verbs
    plugin :symbol_views
    plugin :cookies, domain: SknSettings.skn_base.session_domain, path: '/'
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
    plugin :view_options
    plugin :public             #:static, %w[/images /fonts]
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
       view :http_404, path: File.expand_path('views/http_404.html.erb', opts[:root])
    end
    plugin :error_handler do |uncaught_exception|
      # response.status = 404
      view :unknown, locals: {exception: uncaught_exception }, path: File.expand_path('views/unknown.html.erb', opts[:root])
    end

    # ##
    # Placed Here so Flash and Cookie plugins can add instance methods to Roda
    # ##
    use Warden::Manager do |manager|
      manager.default_scope = :access_profile
      manager.default_strategies :api_auth, :remember_token, :password, :not_authenticated
      manager.scope_defaults :access_profile, {
          store: true,
          strategies: [:password, :not_authenticated],
          action: 'sessions/unauthenticated' }
      manager.failure_app = self
      manager[:public_pages] = SknSettings.security.public_pages
    end

    if SknSettings.env.test?
      use RackSessionAccess::Middleware
    end

    # ##
    # Routing Table
    # ##
    route do |r|

      r.assets unless SknSettings.env.production?

      r.public

      r.on(['fonts', 'images']) do
        r.public
      end

      r.multi_route

      warden_messages

      r.root do
        flash.now[:success] = ['Welcome to Home Page!', 'Multiple Messages Are Supported']
        flash.now[:info] = ['All messages time out!', 'Except for :danger or Error messages!']
        flash.now[:warning] = "Single messages are also supported!"
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

