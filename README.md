# SknBase
An exploration into Dry-Rb and Roda tooling for Ruby Applications


### Notes
<dl>
    <dt>Start Server with Puma, Port 3000:</dt>
        <dd><code>$ bundle exec puma config.ru -v</code></dd>
    <dt>Start Server with RackUp, Port 9292:</dt>
        <dd><code>$ rackup</code></dd>
    <dt>Start Console with Pry:</dt>
        <dd><code>$ bin/console</code></dd>
    <dt>Start Console with RackSh:</dt>
        <dd><code>$ bundle exec racksh</code></dd>
    <dt>Setup Application:</dt>
        <dd><code>$ bin/setup</code></dd>
</dl>


`puma` or `rackup` commands alone will start the server. But wont read puma's config which means the default port maybe 9292 vs 3000.
`Roda's` RodaApp.freeze.app uses RackBuilder to create an Rack App, which confuses the more deliberate `Rack::Handler::Puma.reun(app)` method.

`racksh` is a console for Rack based applications, see docs at [Gem RackSh](https://github.com/sickill/racksh)
In racksh console: `$ $rack.get "/", {}, { 'REMOTE_ADDR' => '127.0.0.1' }`

### Under Consideration
1. What directory structure is required, and what options are there to override those requirements?
    * Seems Roda and Dry-Rb both impose a filesystem structure.
    * Would a Ruby Gem filesystem model be suitable?
2. How does activities per-request factor into things like singletons, or Object lifecycles?
3. What survives each request, must there be singletons to hold AccessRegistry, Persistence, etc?
4. Ruby $LoadPath vs Bundler vs Application Source AutoLoad seem to be at odds, in some ways.
5. While the notion of Sub-Apps is valid for large applications, it also serves to segment application source into domains.
    * A sub-app filesystem structure is relevant for the web interface, it becomes clumsy for Domains.


### Persistence Template
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
