# File routes/users.rb
#
module Skn
  class SknBase

    route 'sessions' do |r|

      set_view_subdir 'sessions'

      r.on 'signin' do
        r.get do
          warden_messages
          view(:signin)
        end

        r.post do
          # request.params[:sessions] => {"username"=>"developer", "password"=>"developer99", "remember_me_token"=>"1"}
          authenticate!(message: 'You have been Signed in!', roda_request: request) # unless authenticated? # double posted
          warden_messages
          r.redirect(redirect_to_origin)
        end
      end

      r.is 'logout' do
        logout
        warden_messages
        r.redirect request.base_url
      end

      r.is 'unauthenticated' do
        response.status = 203
        warden_messages
        view(:unauthenticated)
      end

    end
  end
end


