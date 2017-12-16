# ./skn_base.rb


Bundler.setup(:default, ENV['RACK_ENV'].to_sym)

require "roda"

require "rom"
require "rom-sql"

require "bcrypt"
require "rack/protection"

class SknBase < Roda
  plugin :static, ["/images", "/css", "/js"]
  plugin :render
  plugin :head

  plugin :error_handler

  use Rack::Session::Cookie, secret: "some_nice_long_random_string_DSKJH4378EYR7EGKUFH", key: "_skn_base_session"
  use Rack::Protection

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

    # error do |e|
    #   self.class[:rack_monitor].instrument(:error, exception: e)
    #   raise e
    # end

  end

end
