# File routes/profiles.rb
#
module Skn
  class SknBase
    route('profiles') do |r|

      login_required?

      set_view_subdir 'profiles'

      warden_messages

      r.get "resources" do
        view(:resources)
      end

      r.get "users" do
        view(:users)
      end

    end
  end
end
