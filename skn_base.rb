# File: ./skn_base.rb
# Desc: Main Application entry point

require_relative "boot"

class SknBase < Roda

  use Rack::Session::Cookie, secret: SknSettings.skn_base.secret, key: "_skn_base_session", domain: '.skoona.net'
  use Rack::Protection
  use Rack::MethodOverride

  if SknSettings.env.development?
    use Rack::Reloader
    use BetterErrors::Middleware

    BetterErrors.application_root = __dir__
    BetterErrors.use_pry!
    BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP'] if ENV['TRUSTED_IP']
    # REf: https://github.com/charliesome/better_errors/wiki/Link-to-your-editor
    BetterErrors.editor = 'idea://open?file=%{file}&line=%{line}'
  end

  plugin :all_verbs
  plugin :symbol_views
  plugin :view_options
  plugin :content_for
  plugin :head
  plugin :csrf
  plugin :render, {
      engine: 'html.erb',
      allowed_paths: %w[views views/layouts views/profiles assets/css assets/js ],
      layout: '/application',
      layout_opts: {views: 'views/layouts'}
  }
  plugin :static, %w[/images /fonts]
  plugin :multi_route

  plugin :assets,
         css_dir: 'stylesheets',
         js_dir: 'javascript',
         css: ['skn_base.css.scss' ] ,
         js: ['jquery-2.1.3.js', 'bootstrap-3.3.7.js', 'skn_base.js'],
         dependencies: {'_bootstrap.scss' => Dir['assets/stylesheets/**/*.scss'] }

  # TODO: Experiment with direct file and/or minimized sources
  # plugin :assets, {
  #     css: "bootstrap.css",
  #     js: ["jquery-3.2.1.min.js", "bootstrap.js"]
  # }

  # TODO: Experiment with Gem-Based files
  # plugin :assets, {
  #       css: 'bootstrap.scss.indirect' ,
  #        js: 'bootstrap.js.indirectraw',
  #        dependencies: {
  #            Bootstrap.stylesheets_path + '_bootstrap.scss' => Dir[Bootstrap.stylesheets_path + '/**/*.scss'],
  #        }
  # }

  plugin :not_found do
     view :http_404
  end
  plugin :error_handler do
    view :unknown
  end

  # Named Routes
  Dir['./routes/*.rb'].each{|f| require f}

  # view helpers
  Dir['./views/helpers/*.rb'].each{|f| require f}

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
