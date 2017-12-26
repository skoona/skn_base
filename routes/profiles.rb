# File routes/profiles.rb
#
class SknBase
  route('profiles') do |r|
    set_view_subdir 'profiles'

    r.get "content" do
      view(:content)
    end

  end
end