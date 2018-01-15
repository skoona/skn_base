# File routes/profiles.rb
#
module Skn
  class SknBase
    route('profiles') do |r|

      login_required?

      set_view_subdir 'profiles'

      r.get "resources" do
        resources = registry_service.resources
        view(:resources, locals: {resources: resources})
      end

      r.get "api_get_demo_content_object" do
        content = registry_service.get_content_object
        if content.success
          request.send_file(content.payload, disposition: :inline, filename: content.filename, type: content.content_type)
        else
          response.status = 404
          Utils::APIErrorPayload.call(:not_found, :not_found, "Request: #{request.env['REQUEST_URI']}, Message: #{content.message}")
        end
      end

      r.get "users" do
        view(:users)
      end

    end
  end
end
