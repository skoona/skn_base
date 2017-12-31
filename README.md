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

ActiveRecord Serialization for Arrays with YAML format was handled, since I can't change the data model, via Dry-Types.
```ruby
##
# added to Types:
##
module Types
  include Dry::Types.module

  Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  SerializedArrayRead = Types.Constructor(Types.Array(Types::Strict::String)) { |yaml_str| Psych.load(yaml_str) }
  SerializedArrayWrite = Types.Constructor(Types::Strict::String) { |ary_of_str| Psych.dump(ary_of_str) }
end

##
# Entity
##

    class ContentProfileEntry < Dry::Struct
      # attribute :id, Types::Strict::Int
      attribute :topic_value, Types::Strict::Array.meta(desc: :yaml_array)
      attribute :topic_type, Types::Strict::String
      attribute :topic_type_description, Types::Strict::String
      attribute :content_value, Types::Strict::Array.meta(desc: :yaml_array)
      attribute :content_type, Types::Strict::String
      attribute :content_type_description, Types::Strict::String
      attribute :description, Types::Strict::String
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time
    end

##
# ROM
##

    config.relation(:content_profile_entries) do
      schema(infer: false) do
        attribute :id, Types::Strict::Int.meta(primary_key: true)
        attribute :topic_value, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
        attribute :topic_type, Types::Strict::String
        attribute :topic_type_description, Types::Strict::String
        attribute :content_value, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
        attribute :content_type, Types::Strict::String
        attribute :content_type_description, Types::Strict::String
        attribute :description, Types::Strict::String
        attribute :created_at, Types::Strict::Time
        attribute :updated_at, Types::Strict::Time

        primary_key :id
      end

      struct_namespace Entity
      auto_struct true
    end

```


## Naming
* Relation Table Names should be plural form
* SQL Table names should be plural
* Relations themselves should be plural and match the real-sql table name
* Entities representing a relation should be singular
* Entities composed of other entities must use relation-name (plural) as the attribute keyname
* Repositories can be named anything since they specify the relation name in their constructor

```ruby
Relations
    class ProfileTypes < ROM::Relation[:sql]
        schema(:profile_types, ...
    end

Entity
    class ProfileType < Dry::Struct
        attribute :content_profiles, Types.Constructor(ContentProfile)
    end
```


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
9. Planning to switch from Bootstrap to Semantic-UI after a bit.


### File Tree
```bash
[SknBase]
    .
    ├── assets
    │   ├── stylesheets/        - Sass based CSS
    │   └── javascript/         - JQuery, BootStrap, and general Javascript
    ├── config
    │   ├── settings/           - SknSettings Environment-biased Application Settings
    │   ├── puma.rb
    │   ├── settings.yml        - Default Application Settings
    │   └── version.rb          - Application Version Object
    ├── config.ru               - Rack Initializer
    ├── main
    │   ├── skn_base.rb         - Main Roda Web App/Adapter
    │   └── boot.rb             - LoadPath Management and Log file setup
    ├── persistence
    │   ├── entity              - Entity Structs for User and Profile entities
    │   ├── relations           - Users and Profiles definitions
    │   ├── repositories        - User and Profile repos
    │   └── persistence.rb      - ROM-RB setup
    ├── public
    │   ├── images/             - View Images
    │   └── fonts/              - View Fonts
    ├── routes
    │   ├── profiles.rb         - Profile Routes
    │   └── users.rb            - User Routes
    ├── strategy                - Business UseCases
    └── views
        ├── helpers/            - View HTML Helpers
        ├── layouts/            - Site Layout
        ├── profiles/           - Profile Pages
        ├── users/              - User Pages
        ├── about.html.erb      - Root Pages...
        ├── contact.html.erb
        ├── homepage.html.erb
        ├── http_404.html.erb
        ├── http_500.html.erb
        └── unknown.html.erb

```


### Code Cache
```ruby

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