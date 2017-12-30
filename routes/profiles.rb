# File routes/profiles.rb
#
module Skn
  class SknBase
    route('profiles') do |r|
      set_view_subdir 'profiles'

      r.get "resources" do
        view(:resources)
      end

    end
  end
end
