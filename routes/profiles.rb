# File routes/profiles.rb
#
module Skn
  class SknBase
    route('profiles') do |r|

      login_required?

      set_view_subdir 'profiles'

      r.get "resources" do
        resources = Services::Content::CommandHandler.call(
            Services::Content::Commands::RetrieveAvailableResources.new(username: current_user.username)
        )
        view(:resources, locals: {resources: resources})
      end

      r.get "api_get_demo_content_object" do
        content = Services::Content::CommandHandler.call(
            Services::Content::Commands::RetrieveResourceContent.new( {
                                                                          id: r.params['id'],
                                                                          username: current_user.username,
                                                                          content_type: r.params['content_type']
                                                                      })
        )
        if content.success
          request.send_file(content.payload, disposition: :inline, filename: content.filename, type: content.content_type)
        else
          response.status = 404
          {message: content.message}.merge(r.params)
        end
      end

      r.get "users" do
        view(:users)
      end

    end
  end
end
