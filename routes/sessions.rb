# File routes/users.rb
#
module Skn
  class SknBase

    route 'sessions' do |r|

      set_view_subdir 'sessions'

      r.on 'signin' do
        r.get do
          view(:signin)
        end

        r.post do
          # request.params[:sessions] => {
          #   "username"=>"developer",
          #   "password"=>"developer99",
          #   "remember_me_token"=>"1"
          # }
          authenticate! # unless authenticated? # double posted
          r.redirect(redirect_to_origin)
        end
      end

      r.is 'logout' do
        logout
        flash_message(:success, "You have been signed out!")
        r.redirect request.base_url
      end

      r.is 'unauthenticated' do
        response.status = 409  # The request could not be completed due to a conflict with the current state of the resource.
        view('unauthenticated')
      end

    end
  end
end


