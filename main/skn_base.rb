# File: ./main/skn_base.rb
# Desc: Main Application entry point

require_relative "boot"

module Skn
  class SknBase < Roda

    use Rack::CommonLogger, Logging.logger['WEB']
    use Rack::Session::Cookie, secret: SknSettings.skn_base.secret, key: "_skn_base_session", domain: '.skoona.net'
    use Rack::Protection
    use Rack::MethodOverride

    use Rack::Reloader  if SknSettings.env.development?
    use Rack::ShowExceptions

    plugin :all_verbs
    plugin :symbol_views
    plugin :view_options
    plugin :content_for
    plugin :head
    plugin :csrf
    plugin :render, {
        engine: 'html.erb',
        allowed_paths: ['views', 'views/layouts', 'views/profiles', 'views/users'],
        layout: '/application',
        layout_opts: {views: 'views/layouts'}
    }
    plugin :static, %w[/images /fonts]
    plugin :multi_route

    plugin :assets,
           css_dir: 'stylesheets',
           js_dir: 'javascript',
           css: ['skn_base.css.scss' ] ,
           js: ['jquery-3.2.1.js', 'bootstrap-3.3.7.js', 'jquery.matchHeight.js', 'bootstrap-select.js',
                'jquery.dataTables.js', 'dataTables.bootstrap.js', 'skn-base.custom.js'],
           dependencies: {'_bootstrap.scss' => Dir['assets/stylesheets/**/*.scss', 'assets/stylesheets/*.scss'] }

    plugin :not_found do
       view :http_404, path: File.expand_path('../views/http_404.html.erb', __dir__)
    end
    plugin :error_handler do |uncaught_exception|
      # response.status = 404
      view :unknown, locals: {exception: uncaught_exception }, path: File.expand_path('../views/unknown.html.erb', __dir__)
    end

    route do |r|

      r.root do
        view(:homepage)
      end

      r.get "about" do
        view(:about)
      end

      r.get "contact" do
        view(:contact)
      end

      r.multi_route

      r.assets unless SknSettings.env.production?

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

