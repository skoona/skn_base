# File: ./skn_base.rb
# Desc: Main Application entry point

require_relative "boot"

class SknBase < Roda

  use Rack::Reloader
  use Rack::Session::Cookie, secret: "37ae095d4e6ad226c79a03393f743d6c4f4f34f6123b9bef537beade8f364c36f9f7b10192ccd29c9ca4e75bff4207929304132849d0defc803a926406bb8876", key: "_skn_base_session"
  use Rack::Protection

  plugin :static, ["/images", "/css", "/js"]
  plugin :render
  plugin :content_for
  plugin :head

  plugin :error_handler

  plugin :csrf

  route do |r|
    
    r.root do
      view("homepage")
    end

    r.get "about" do
      view("about")
    end

    r.get "contact" do
      view("contact")
    end

    r.get "sitemap.xml" do
      # @posts = Post.reverse_order
      response["Content-Type"] = "text/xml"
      render("sitemap", ext: 'builder')
    end

    error do |e|
      self.class[:rack_monitor].instrument(:error, exception: e)
      raise e
    end

  end

end
