# ./skn_base.rb

require "roda"

class SknBase < Roda
  plugin :static, ["/images", "/css", "/js"]
  plugin :render
  plugin :head

  plugin :error_handler

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
