# File: ./skn_base.rb
# Desc: Main Application entry point

require_relative "boot"

class SknBase < Roda

  use Rack::CommonLogger, SknSettings.logger
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

  plugin :not_found do
     view :http_404
  end
  plugin :error_handler do
    view :unknown
  end

  # plugin :default_headers, {
  #        'Content-Type'=>'text/html',
  #        'Content-Security-Policy'=>"default-src 'self' https://oss.maxcdn.com/ https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com",
  #        #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access
  #        'X-Frame-Options'=>'deny',
  #        'X-Content-Type-Options'=>'nosniff',
  #        'X-XSS-Protection'=>'1; mode=block'
  # }

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
