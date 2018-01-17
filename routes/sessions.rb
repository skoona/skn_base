# File routes/users.rb
#
module Skn
  class SknBase

    route 'sessions' do |r|

      set_view_subdir 'sessions'

      r.on 'signin' do

        r.post do
          # request.params[:sessions] => {
          #   "username"=>"developer",
          #   "password"=>"developer99",
          #   "remember_me_token"=>"1"
          # }
          authenticate!(:password, :not_authenticated) # unless authenticated? # double posted
          response.status = 201
          r.redirect(redirect_to_origin)
        end

        r.get do
          response.status = 200
          view(:signin)
        end
      end

      r.is 'logout' do
        logout
        flash_message(:success, "You have been signed out!")
        r.redirect request.base_url
      end

      r.is 'unauthenticated' do
        response.status = 202  # The request could not be completed due to a conflict with the current state of the resource.
        view('unauthenticated')
      end

    end
  end
end


