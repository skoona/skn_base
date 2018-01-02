# File routes/profiles.rb
#
module Skn
  class SknBase
    route('profiles') do |r|
      SknSettings.logger.debug "DEBUG: PROFILES-ROUTE PASSING => #{request.path}, REQUEST-METHOD => #{request.request_method}"

      login_required?
      set_view_subdir 'profiles'

      r.get "resources" do
        warden_messages
        view(:resources)
      end

      r.get "users" do
        warden_messages
        view(:users)
      end

    end
  end
end

# flash_message(:notice, warden.errors.full_messages) if warden.message.present?
# flash_message(:alert, warden.errors.full_messages) unless warden.errors.empty?
