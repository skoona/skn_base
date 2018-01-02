# File routes/users.rb
#
module Skn
  class SknBase

    route 'sessions' do |r|
      SknSettings.logger.debug "DEBUG: #{r.class.to_s} SESSIONS-ROUTE PASSING => #{request.path}, MEDIA-TYPE => #{request&.media_type}, REQUEST-METHOD => #{request.request_method}"

      set_view_subdir 'sessions'

      r.get 'signin' do
        warden_messages
        view(:signin)
      end

      r.post 'signin' do
        # request.params[:sessions] => {"username"=>"developer", "password"=>"developer99", "remember_me_token"=>"1"}
        authenticate! unless authenticated? # double posted
        warden_messages
        r.redirect(redirect_to_origin)
      end

      r.is 'logout' do
        logout(message: 'You have been logged out!')
        warden_messages
        response.delete_cookie( SknSettings.skn_base.session_key.to_sym )
        r.redirect request.base_url
      end

      r.is 'unauthenticated' do
        session[:return_to] = env['warden.options'][:attempted_path]
        warden_messages
        request.path_info ="/sessions/signin"
        # response.status = 403
        # r.redirect('/sessions/signin')
        view(:signin)
      end

    end
  end
end


