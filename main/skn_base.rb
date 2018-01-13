# File: ./main/skn_base.rb
# Desc: Main Application entry point

require_relative "boot"

module Skn
  class SknBase < Roda

    opts[:root] = Pathname(__FILE__).join("..").realpath.dirname.freeze

    use Rack::CommonLogger

    use Rack::Cookies
    use Rack::Session::Cookie, {
        secret: SknSettings.skn_base.secret,
        key: SknSettings.skn_base.session_key,
        domain: SknSettings.skn_base.session_domain
    }

    use RackSessionAccess::Middleware if SknSettings.env.test?

    # ##
    # Placed Here so Flash and Cookie plugins can add instance methods to Roda
    # ##
    use Warden::Manager do |config|
      config.default_scope = :access_profile
      config.default_strategies [:api_auth, :remember_token, :password, :not_authenticated]
      config.scope_defaults :access_profile, {
          store: true,
          strategies: [:password, :remember_token, :api_auth, :not_authenticated],
          action: 'sessions/unauthenticated' }
      config.failure_app = self
      config[:public_pages] = SknSettings.security.public_pages
      config[:production] = SknSettings.env.production?
      config[:asset_paths_ary] = SknSettings.security.asset_paths
      config[:sys_logger] = (Logging.logger['WAR'] || SknSettings.logger)
      config[:session_expires] = SknSettings.security.session_expires.to_i
      config[:remember_for] = SknSettings.security.remembered_for.to_i
    end

    use Rack::MethodOverride

    unless SknSettings.env.test?
      use Rack::Protection
    end

    use Rack::ShowExceptions
    use Rack::NestedParams
    use Rack::Reloader

    plugin :all_verbs

    unless SknSettings.env.test?
      plugin :csrf, { raise: false,
                      skip_if: lambda { |request|
                        ['HTTP_AUTHORIZATION', 'X-HTTP_AUTHORIZATION',
                         'X_HTTP_AUTHORIZATION', 'REDIRECT_X_HTTP_AUTHORIZATION'].any? {|k|
                          request.env.key?(k) }
                      }
      }
    end

    plugin :render, {
        engine: 'html.erb',
        allowed_paths: ['views', 'views/layouts', 'views/profiles', 'views/sessions'],
        layout: '/application',
        layout_opts: {views: 'views/layouts'}
    }
    plugin :assets, {
        css_dir: 'stylesheets',
        js_dir: 'javascript',
        css: ['skn_base.css.scss' ] ,
        js: ['jquery-3.2.1.js', 'bootstrap-3.3.7.js', 'jquery.matchHeight.js', 'bootstrap-select.js',
             'jquery.dataTables.js', 'dataTables.bootstrap.js', 'skn-base.custom.js'],
        dependencies: {'_bootstrap.scss' => Dir['assets/stylesheets/**/*.scss', 'assets/stylesheets/*.scss'] }
    }
    plugin :view_options
    plugin :symbol_views
    plugin :content_for
    plugin :tag_helpers        # includes :tag plugin, for HTML generation: https://github.com/kematzy/roda-tags/

    plugin :i18n, :locale => ['en']
    plugin :json
    plugin :json_parser

    plugin :public             #replaces plugin :static, %w[/images /fonts]
    plugin :head
    plugin :flash
    plugin :not_found do
      view :http_404, path: File.expand_path('views/http_404.html.erb', opts[:root])
    end
    plugin :error_handler do |uncaught_exception|
      # response.status = 404
      view :unknown, locals: {exception: uncaught_exception }, path: File.expand_path('views/unknown.html.erb', opts[:root])
    end

    plugin :multi_route

    # ##
    # Routing Table
    # ##
    route do |r|

      r.assets unless SknSettings.env.production?

      r.public

      r.on(['fonts', 'images']) do
        r.public
      end

      warden_messages

      r.root do
        flash_message(:success, ['Welcome to Home Page!', 'Multiple Messages Are Supported'], true)
        flash_message(:info, ['All messages time out!', 'Except for :danger or Error messages!'], true)
        flash_message(:warning, "Single messages are also supported!", true)
        view(:homepage)
      end

      r.get "about" do
        view(:about)
      end

      r.get "contact" do
        view(:contact)
      end

      r.multi_route

    end # End Routing Tree

  end
end

# Named Routes and view helpers
Dir['./routes/*.rb', './views/helpers/*.rb'].each{|f| require f }

# ##
#
# Load Business Logic after this mark.
# - Loadpath has been established and all gems have been required.
#
# ##

