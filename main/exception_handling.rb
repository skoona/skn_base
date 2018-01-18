# ##
# File: ./main/exception_handling.rb
# - Rack app to handle 500 errors, as a last hope!
#

class ExceptionHandling
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call env
    rescue => e
      env['rack.input'].rewind
      body = env['rack.input'].read
      h=if 'production'.eql?(env['RACK_ENV'])

          #in production we don't give any specific error messages. It's just a generic message
          msg = "Something went wrong, please contact the administrations and give them the following information\n

                      REQUEST_METHOD=>#{env[REQUEST_METHOD]}\n
                       PATH_INFO=>#{env[PATH_INFO]}\n
                       BODY=> #{body}"
          {message: msg}
        else
          {message: e.message, backtrace: e.backtrace}
        end

      [500, {'Content-type' => 'application/json'}, MultiJson.dump(h)]
    end
  end
end
