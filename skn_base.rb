# File: ./skn_base.rb
# Desc: Main Application entry point

require_relative "boot"

class SknBase < Roda


  use Rack::Session::Cookie, secret: SknSettings.skn_base.secret, key: "_skn_base_session", domain: '.skoona.net'
  use Rack::Protection
  use Rack::MethodOverride

  if ENV['RACK_ENV'].to_sym == :development
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
  plugin :render, engine: 'html.erb', layout: 'layout'
  plugin :static, %w[/images /css /js /fonts]
  plugin :content_for
  plugin :head
  plugin :csrf
  plugin :multi_route
  # plugin :error_handler

  plugin :default_headers,
         'Content-Type'=>'text/html',
         'X-Frame-Options'=>'deny',
         'X-Content-Type-Options'=>'nosniff',
         'X-XSS-Protection'=>'1; mode=block'
         # 'Content-Security-Policy'=>"default-src 'self' https://oss.maxcdn.com https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com",
         #'Strict-Transport-Security'=>'max-age=16070400;', # Uncomment if only allowing https:// access

  route do |r|
    
    r.root do |x|
      view(:homepage, locals: {rq: r})
    end

    r.get "about" do |x|
      view(:about, locals: {rq: r})
    end

    r.get "contact" do |x|
      view(:contact, locals: {rq: r})
    end

    r.get "sitemap.xml" do
      # @posts = Post.reverse_order
      response["Content-Type"] = "text/xml"
      render("sitemap", ext: 'builder')
    end

    r.multi_route

    # r.assets

    # error do |e|
    #   self.class[:rack_monitor].instrument(:error, exception: e)
    #   raise e
    # end
  end

  # view helpers
  def menu_active?(item_path)
    request.path.eql?(item_path) ? 'active' : ''
  end

end
