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
  ARSerializedRead = Types.Constructor(Types.Array(Types::Strict::String)) { |yaml_str| Psych.load(yaml_str) }
  ARSerializedWrite = Types.Constructor(Types::Strict::String) { |ary_of_str| Psych.dump(ary_of_str) }
end

##
# Entities
##
module Skn
  module Entities

    class ProfileType < Dry::Struct
      # attribute :id, Types::Strict::Int
      attribute :name, Types::String
      attribute :description, Types::String
    end

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

    class ContentProfile < Dry::Struct
      # attribute :id, Types::Strict::Int
      attribute :person_authentication_key, Types::Strict::String
      attribute :authentication_provider, Types::Strict::String
      attribute :username, Types::Strict::String
      attribute :display_name, Types::Strict::String
      attribute :email, Types::Email
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time

      attribute :profile_type, Types.Constructor(ProfileType)
    end

    class ProfileEntry < Dry::Struct
      # attribute :id, Types::Strict::Int
      attribute :person_authentication_key, Types::Strict::String
      attribute :authentication_provider, Types::Strict::String
      attribute :username, Types::Strict::String
      attribute :display_name, Types::Strict::String
      attribute :email, Types::Email
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time

      attribute :profile_type, Types.Constructor(ProfileType)
      attribute :content_profile_entries, Types::Array.of(ContentProfileEntry)
    end

  end
end

##
# ROM
##
module Skn
  SknSettings.rom = ROM.container(:sql, SknSettings.postgresql.url,
                       user: SknSettings.postgresql.user,
                       password: SknSettings.postgresql.password) do |config|

    config.gateways[:default].use_logger(Logging.logger['ROM'])

    config.relation(:content_profiles) do
      schema(infer: false) do
        attribute :id, Types::Strict::Int.meta(primary_key: true)
        attribute :person_authentication_key, Types::Strict::String
        attribute :profile_type_id, Types::Int.meta(foreign_key: true, relation: :profile_type)
        attribute :authentication_provider, Types::Strict::String
        attribute :username, Types::Strict::String
        attribute :display_name, Types::Strict::String
        attribute :email, Types::Email
        attribute :created_at, Types::Strict::Time
        attribute :updated_at, Types::Strict::Time

        primary_key :id

        associations do
          belongs_to :profile_type
          has_many   :content_profile_entries, through: :content_profiles_entries #, view: :ordered
        end
      end

      struct_namespace Skn::Entities
      auto_struct true
    end

    config.relation(:content_profile_entries) do
      schema(infer: false) do
        attribute :id, Types::Strict::Int.meta(primary_key: true)
        attribute :topic_value, Types::ARSerializedWrite.meta(desc: :yaml_array), read: Types::ARSerializedRead.meta(desc: :yaml_array)
        attribute :topic_type, Types::Strict::String
        attribute :topic_type_description, Types::Strict::String
        attribute :content_value, Types::ARSerializedWrite.meta(desc: :yaml_array), read: Types::ARSerializedRead.meta(desc: :yaml_array)
        attribute :content_type, Types::Strict::String
        attribute :content_type_description, Types::Strict::String
        attribute :description, Types::Strict::String
        attribute :created_at, Types::Strict::Time
        attribute :updated_at, Types::Strict::Time

        primary_key :id
      end

      # view(:ordered) do
      #   schema do
      #     append(relations[:content_profiles_entries][:content_profile_entry_id])
      #   end
      #
      #   relation do
      #     where(content_profile_id: :content_profile_id).order(:content_profile_entry_id)
      #   end
      # end

      struct_namespace Skn::Entities
      auto_struct true
    end

    config.relation(:profile_types) do
      schema(infer: false) do
        attribute :id, Types::Strict::Int.meta(primary_key: true)
        attribute :name, Types::Strict::String
        attribute :description, Types::Strict::String
        attribute :created_at, Types::Strict::Time
        attribute :updated_at, Types::Strict::Time

        primary_key :id
      end

      struct_namespace Skn::Entities
      auto_struct true
    end

    config.relation(:content_profiles_entries) do
      schema(infer: false) do

        attribute :id, Types::Strict::Int.meta(primary_key: true)
        attribute :content_profile_id, Types::Int.meta(foreign_key: true, relation: :content_profiles)
        attribute :content_profile_entry_id, Types::Int.meta(foreign_key: true, relation: :content_profile_entries)

        primary_key :id

        associations do
          belongs_to :content_profiles
          belongs_to :content_profile_entries
        end
      end
    end
  end
end

##
# Outcome
##
[1] pry(main)> x = Skn::Persistence::Profiles.new(SknSettings.rom).entry_info_by_pak('df1d31b19872db300aa3130d93729499')
2017-12-28 01:26:05.922 ROM:INFO  (0.001542s) SELECT "content_profiles"."id", "content_profiles"."person_authentication_key", "content_profiles"."profile_type_id", "content_profiles"."authentication_provider", "content_profiles"."username", "content_profiles"."display_name", "content_profiles"."email", "content_profiles"."created_at", "content_profiles"."updated_at" FROM "content_profiles" WHERE ("person_authentication_key" = 'df1d31b19872db300aa3130d93729499') ORDER BY "content_profiles"."id"
2017-12-28 01:26:06.681 ROM:INFO  (0.000650s) SELECT "profile_types"."id", "profile_types"."name", "profile_types"."description", "profile_types"."created_at", "profile_types"."updated_at" FROM "profile_types" WHERE ("profile_types"."id" IN (7)) ORDER BY "profile_types"."id"
2017-12-28 01:26:06.716 ROM:INFO  (0.034263s) SELECT "content_profile_entries"."id", "content_profile_entries"."topic_value", "content_profile_entries"."topic_type", "content_profile_entries"."topic_type_description", "content_profile_entries"."content_value", "content_profile_entries"."content_type", "content_profile_entries"."content_type_description", "content_profile_entries"."description", "content_profile_entries"."created_at", "content_profile_entries"."updated_at", "content_profiles_entries"."content_profile_id" FROM "content_profile_entries" INNER JOIN "content_profiles_entries" ON ("content_profiles_entries"."content_profile_entry_id" = "content_profile_entries"."id") INNER JOIN "content_profiles" ON ("content_profiles"."id" = "content_profiles_entries"."content_profile_id") WHERE ("content_profiles_entries"."content_profile_id" IN (7)) ORDER BY "content_profile_entries"."id"
=> #<Skn::Entities::ProfileEntry person_authentication_key="df1d31b19872db300aa3130d93729499" authentication_provider="SknService::Bcrypt" username="vptester" display_name="Vendor Primary User" email="appdev4@localhost.com" created_at=2017-12-06 04:10:47 -0500 updated_at=2017-12-06 04:10:47 -0500
        profile_type=#<Skn::Entities::ProfileType name="VendorPrimary" description="Partner Manager">
        content_profile_entries=[
            #<Skn::Entities::ContentProfileEntry topic_value=["0099"] topic_type="Partner" topic_type_description="This Corporate Account" content_value=["*.pdf"] content_type="Activity" content_type_description="Partner Relationship Reports" description="Partner Relationship Reports" created_at=2017-12-06 04:10:46 -0500 updated_at=2017-12-06 04:10:46 -0500>,
            #<Skn::Entities::ContentProfileEntry topic_value=["VendorPrimary"] topic_type="UserGroups" topic_type_description="Shared access to project working files" content_value=["*.log"] content_type="FileDownload" content_type_description="Project Related Resources" description="Shared access to project working files" created_at=2017-12-06 04:10:46 -0500 updated_at=2017-12-06 04:10:46 -0500>
        ]>


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