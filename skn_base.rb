# File: ./skn_base.rb
# Desc: Main Application entry point

require_relative "boot"

class SknBase < Roda

  use Rack::Session::Cookie, secret: "37ae095d4e6ad226c79a03393f743d6c4f4f34f6123b9bef537beade8f364c36f9f7b10192ccd29c9ca4e75bff4207929304132849d0defc803a926406bb8876", key: "_skn_base_session"
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
  plugin :static, ["/images", "/css", "/js"]
  plugin :content_for
  plugin :head
  plugin :csrf
  # plugin :error_handler

  route do |r|
    
    r.root do
      view("homepage")
    end

    r.get "about" do
      view(:about)
    end

    r.get "contact" do
      view(:contact)
    end

    r.get "sitemap.xml" do
      # @posts = Post.reverse_order
      response["Content-Type"] = "text/xml"
      render("sitemap", ext: 'builder')
    end

    # error do |e|
    #   self.class[:rack_monitor].instrument(:error, exception: e)
    #   raise e
    # end

  end

end
