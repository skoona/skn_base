# SknBase
An exploration into [Dry-Rb](http://dry-rb.org), [ROM-Rb](http://rom-rb.org), [Roda](https://github.com/jeremyevans/roda), and [Ruby-Event-Store](https://github.com/RailsEventStore/rails_event_store) tooling for Ruby Web Applications.

In concept, I plan to create a `runtime` for [SknServices](https://github.com/skoona/SknServices) content security application.  Where SknServices provides Admin features, this application would become the runtime consumer of those features.

I'm looking for an alternative way to build enterprise ruby web applications.  I've tried Rails and salute it for it's Web Interface and Web framework.  However, I've never been comfortable with it's MVC development model for enterprise applications.

I'm finding that most ruby web tools are as opinionated as Rails.  The difference being tools like Roda, as web interface, allow you to override its conventions through configuration; the reversal is not lost on me!

For now I will keep notes and comments here, until I get to a workable baseline.

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

`plugin: multi_route` has a very strange structure for associated route files.
```Ruby
# File: ./routes/prefix.rb

class SknBase
    route('prefix') do
      ...
    end
end
```
It re-uses (and I think redefines the app name class).  `SknBase` is also the name of this apps main.  Helper files have the same behavior.

The assets plugin initially failed (HTTP-404) to send bootstrap.css at Roda V3.3.0.  Switched to 2.29.0 and it worked, tried 3.3.0 again and everything seems to work now!  Making this note in case the trouble shows again.
Asset Plugin Failure: Sending bottstrap.css with a 'Content-Type' eq 'text/html' 'Content-Length' eq '3045'; verus 'text/css' and 146K.


### Under Consideration
1. What directory structure is required, and what options are there to override those requirements?
    * Seems Roda and Dry-Rb both impose a filesystem structure.
    * Would a Ruby Gem filesystem model be suitable?
2. How does activities per-request factor into things like singletons, or Object lifecycles?
3. What survives each request, must there be singletons to hold AccessRegistry, Persistence, etc?
4. Ruby $LoadPath vs Bundler vs Application Source AutoLoad seem to be at odds, in some ways.
5. While the notion of Sub-Apps is valid for large applications, it also serves to segment application source into domains.
    * A sub-app filesystem structure is relevant for the web interface, it becomes clumsy for Domains.
6. Several plugin automatically require and instantiate other plugins on their own.  Each plugin has to be reviewed to understand its side effects or dependancies.
7. Require vs AutoLoad? `Autoload` would prevent loading the whole app when it's not needed during test or CLI operations.  However, `Require` does allow me to control what's loaded and any dependancies with greater clarity.
8. Not sure about the lifecycle of critical objects in Roda yet.  How to create something that will survive the request/response cycle; like the database component.


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


### Code Cache

```html
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
```

```ruby
  # TODO: Experiment with direct file and/or minimized sources
  # plugin :assets, {
  #     css: "bootstrap.css",
  #     js: ["jquery-3.2.1.min.js", "bootstrap.js"]
  # }

  # TODO: Experiment with Gem-Based files
  # plugin :assets, {
  #       css: 'bootstrap.scss.indirect' ,
  #        js: 'bootstrap.js.indirectraw',
  #        dependencies: {
  #            Bootstrap.stylesheets_path + '_bootstrap.scss' => Dir[Bootstrap.stylesheets_path + '/**/*.scss'],
  #        }
  # }

```