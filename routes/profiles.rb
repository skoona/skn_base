# File routes/profiles.rb
#
module Skn
  class SknBase
    route('profiles') do |r|

      login_required?(r)
      set_view_subdir 'profiles'

      r.get "resources" do
        flash[:notice] = warden.errors.full_messages unless warden.errors.empty?
        view(:resources)
      end

      r.get "users" do
        flash[:notice] = warden.errors.full_messages unless warden.errors.empty?
        view(:users)
      end

    end
  end
end

# flash_message(:notice, warden.errors.full_messages) if warden.message.present?
# flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
