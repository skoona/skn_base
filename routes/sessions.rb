# File routes/users.rb
#
module Skn
  class SknBase

    route 'sessions' do |r|
      set_view_subdir 'sessions'

      r.get 'signin' do
        view(:signin)
      end

      r.post 'signin' do
        # request.params[:sessions] => {"username"=>"developer", "password"=>"developer99", "remember_me_token"=>"1"}
        warden.authenticate!
        flash[:success] = warden.errors.full_messages

        r.redirect(redirect_to_origin)
      end

      r.delete 'logout' do
        warden.logout
        flash[:notice] = "You are logged out"

        r.redirect request.base_url
      end
      r.get 'logout' do
        warden.logout
        flash[:notice] = "You are logged out"
        session.clear
        r.redirect request.base_url
      end

      r.post 'unauthenticated' do
        session[:return_to] = env['warden.options'][:attempted_path]
        flash[:danger] = warden.errors.full_messages
        response.status = 403

        r.redirect(:signin)
      end

      # end
    end
  end
end


