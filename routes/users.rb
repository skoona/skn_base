# File routes/users.rb
#
module Skn
  class SknBase
    route('users') do |r|
      set_view_subdir 'users'

      r.get "login" do
        view(:login)
      end

      r.post "login" do
        # request.params[:users] => {"username"=>"developer", "password"=>"developer99", "remember_me_token"=>"1"}
        view(:users)
      end

      r.get "users" do
        view(:users)
      end

    end
  end
end
