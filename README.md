# SknBase
An exploration into Dry-Rb and Roda tooling for Ruby Applications


### Notes
1. Start Server with Puma: `$ bundle exec puma config.ru -v`
2. Start Console with Pry: `$ bin/console`
3. Setup Application: `$ bin/setup`

`puma` or `rackup` commands will start server, but wont read puma's config which means the default port will be 9292 vs 3000.
`Roda's` RodaApp.freeze.app uses RackBuilder to create an Rack App, which confuses the more deliberate `Rack::Handler::Puma.reun(app)` method.

`racksh` is a console for Rack based applications, see docs at [Gem RackSh](https://github.com/sickill/racksh)
    In racksh console: `$ $rack.get "/", {}, { 'REMOTE_ADDR' => '127.0.0.1' }`


```ruby
rom = ROM.container(:sql, 'postgres://localhost/SknServices_development', user: 'postgres', password: 'postgres') do |config|

  class ContentProfilesEntries < ROM::Relation[:sql]
    schema(:content_profiles_entries, infer: true) do
      associations do
        belongs_to :content_profiles
        belongs_to :content_profile_entries
      end
    end
  end

  class ProfileType < ROM::Relation[:sql]
    schema(:profile_types, infer: true)
    auto_struct true
  end

  class ContentProfile < ROM::Relation[:sql]
    schema(:content_profiles, infer: true) do
      associations do
        belongs_to :profile_type
        has_many :content_profile_entries, through: :content_profiles_entries
      end
    end
    auto_struct true
  end

  class ContentProfileEntries < ROM::Relation[:sql]
    schema(:content_profile_entries, infer: true) do
      associations do
        has_many :content_profiles, through: :content_profiles_entries
      end
    end
    auto_struct true
  end

  config.register_relation(ContentProfile, ContentProfileEntries, ProfileType, ContentProfilesEntries)
end

cps   = rom.relations[:content_profiles]
cpes  = rom.relations[:content_profile_entries]
pts   = rom.relations[:profile_types]

puts cps.first.inspect
puts cpes.first.inspect
puts pts.first.inspect

puts cps.combine(:profile_type).first.inspect

puts cps.where(id: 1).combine(:profile_type).to_a.map(&:inspect)

puts "Combining..."
p cps.where(id: 1).combine([:profile_type, :content_profile_entries]).to_a

# class ProfileRepo < ROM::Repository[:content_profiles]
# end
#
# cps_repo = ProfileRepo.new(rom)
#
# pp cps_repo.aggregate(:content_profile_entry).one.inspect


end
```
