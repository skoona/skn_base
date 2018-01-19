# SknBase
An exploration into [Dry-Rb](http://dry-rb.org), [ROM-Rb](http://rom-rb.org), and [Roda](https://github.com/jeremyevans/roda) tooling for Ruby Web Applications.

In concept, I plan to create a `runtime` for [SknServices](https://github.com/skoona/SknServices) content security application.  Where SknServices provides Admin features, this application would become the runtime consumer of those features and access content from SknServices using the API it provides for that purpose.

I'm looking for an alternative way to build enterprise ruby web applications.  I've tried Rails and salute it for it's Web Interface and Web framework.  However, I've never been comfortable with it's MVC development model for enterprise applications.

I'm finding that most ruby web tools are as opinionated as Rails.  The difference being tools like Roda, as web interface, allow you to override its conventions through configuration; the reversal is not lost on me!

For now I will keep notes and comments here, until I get to a workable baseline.

## Progress
Before engaging the advanced `Dry-RB` gems and `Gems of Interest`, I thought to code the basic app with minimal assistance from add-ins.  The overall structure of RODA is very flexible, so other than the normal scss/js struggle there were no surprises in the web-component portion; and more importantly, no imposition on business logic structure.

User information is the only database requirement I have right now.  `Rom-Rb` handled that task well even though I've not invested in creating a DB migration needed to create the database and table.  I'm using a copy of a table for an existing demo application: `SknServices`.  As a result `ROM-Rb` is overkill for this task, `Sequel` would be the correct level technology, if I have no further needs for Database services.

`SknService` also offers and ContentAPI which I am using on the `Resources` page.

Instead of using an advanced container and DI gem, I've started out using my `SknUtils` gem; since I was already using it for application settings.  This gem is a thread-safe wrapper over Ruby's Hash, with dot-notation, presence(?) testing, and deep-merge capabilities.  Since a hash can use any object/value as it's Key or Value variables, it works well as a global container for environment based application settings, caching, central/critical application-class instances.

I have adopted the Command and CommandHandler pattern to contain the HTPP Request service used to call the ContentAPI of SknServices.  Commands encapsulate the request params, in a validateable command class, as input to the command handler which will invoke the related service.

To link the the Roda Routes to the appropriate services, I've create a `ServiceRegistry` and File or HTTP wrappers to make the link between the Application Classes and the Web Interface.  The basically moves the lines of code that would have been in the Routes into the ServiceRegistry; which i can mock out as needed for testing later.

Aside from DB migrations, RSPec test coverage, and adding an ERB asset pre-processor, I'm done with this example and very impressed with its structure.


### Gems of Interest
* [SknUtils](https://skoona.github.io/skn_utils/)
* [Roda-i18n](https://github.com/kematzy/roda-i18n)
* [Roda-Container](https://github.com/AMHOL/roda-container)
* [Roda-Action](https://github.com/AMHOL/roda-action)
* [Roda-Flow](https://github.com/AMHOL/roda-flow)
* [Roda-Tags](https://github.com/kematzy/roda-tags)
* [FriendlyNumbers](https://github.com/adam12/friendly_numbers)
* [Roda-Parse-Request](https://github.com/3scale/roda-parse-request)
* [Roda-MessageBus](https://github.com/jeremyevans/roda-message_bus)
* [Ruby-Event-Store](https://github.com/RailsEventStore/rails_event_store)
* [Wisper](https://github.com/krisleech/wisper)
* [Piperator](https://github.com/lautis/piperator)


### Under Consideration
1. What directory structure is required, and what options are there to override those requirements?
    * Seems Roda and Dry-Rb both impose a filesystem structure.
    * Would a Ruby Gem filesystem model be suitable?
    * `Partial` answer is GEM and Roda.Plugin file layouts.
2. How does activities per-request factor into things like singletons, or Object lifecycles?
    * No Impact
3. What survives each request, must there be singletons to hold AccessRegistry, Persistence, etc?
    * DI Containers
4. Ruby $LoadPath vs Bundler vs Application Source AutoLoad seem to be at odds, in some ways.
    * Autoload is of little interest at this scale. Each Dir has a same-named rbfile that requires all its components
    * Bundler.seup and Bundler.require handle loading all gem for now; may change as I dig into RSpec testing.
5. While the notion of Sub-Apps is valid for large applications, it also serves to segment application source into domains.
    * A sub-app filesystem structure is relevant for the web interface, it becomes clumsy for Domains.
    * For now, I will use one single app with multiple routes tohandle the web interface segmentation.
6. Several plugin automatically require and instantiate other plugins on their own.  Each plugin has to be reviewed to understand its side effects or dependancies.
    * This is a pain to be experienced one time.  Middleware and Plugin order DOES MATTER.
7. Require vs AutoLoad? `Autoload` would prevent loading the whole app when it's not needed during test or CLI operations.  However, `Require` does allow me to control what's loaded and any dependancies with greater clarity.
    * Don't really care yet!
8. Not sure about the lifecycle of critical objects in Roda yet.  How to create something that will survive the request/response cycle; like the database component.
    * Again, DI Container maybe helpful.  I'm current using SknUtils::NestedResult class adapted to be a Global Container for regular yaml settings and holding application resources.
9. Planning to switch from Bootstrap to Semantic-UI after a bit.
    * Nope, not doing that.  Bootstrap is fine for the collection of Apps


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
    ├── coverage                - SimpleCov HTML Reports
    ├── docs                    - rubocop HTML Reports
    ├── i18n                    - Message Translation files
    ├── main
    │   ├── skn_base.rb         - Main Roda Web App/Adapter
    │   ├── warden.rb           - Extended Warden Configuration
    │   └── boot.rb             - LoadPath Management and Log file setup
    ├── persistence
    │   ├── entity              - Entity Struct for User
    │   ├── relations           - Users definition
    │   ├── repositories        - User repo
    │   └── persistence.rb      - ROM-RB setup
    ├── public
    │   ├── images/             - View Images
    │   └── fonts/              - View Fonts
    ├── routes
    │   ├── profiles.rb         - Profile Routes
    │   └── users.rb            - User Routes
    ├── strategy                - Business UseCases and Integrations
    │   ├── authentication      - User Management
    │   ├── services            - API services and ServicesRegistry
    │   └── utils               - Application Utilities
    └── views
        ├── helpers/            - View HTML Helpers
        ├── layouts/            - Site Layout
        ├── profiles/           - Profile Pages
        ├── sessions/           - Signin Pages
        ├── about.html.erb      - Root Pages...
        ├── contact.html.erb
        ├── homepage.html.erb
        ├── http_404.html.erb
        ├── http_500.html.erb
        └── unknown.html.erb

```


## Installation
SknBase will need a database of users which should be a shared copy of the table used by SknServices.  This may not be practical, so a pgsql dump file has been includes in the config directory and the following script will install it.
<dl>
    <dt>Start Server with Puma, Port 3000:</dt>
        <dd><code>$ bundle exec puma config.ru -v</code></dd>
    <dt>Start Server with RackUp, Port 9292:</dt>
        <dd><code>$ rackup</code></dd>
    <dt>Start Console with Pry:</dt>
        <dd><code>$ bin/console</code></dd>
    <dt>Start Console with RackSh:</dt>
        <dd><code>$ bundle exec racksh</code></dd>
    <dt>Setup Application and Create Database Tables:</dt>
        <dd><code>$ bin/setup</code></dd>
</dl>


### Problems Sovled
ActiveRecord Serialization for Arrays with YAML format was handled nicely by Dry-Types, since I can't easily change the data model.
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

  class User < ROM::Struct
    attribute :id, Types::Strict::Int
    attribute :username, Types::Strict::String
    attribute :name, Types::Strict::String
    attribute :email, ::Types::Email
    attribute :password_digest, Types::Strict::String
    attribute :remember_token, Types::Strict::String.optional
    attribute :password_reset_token, Types::Strict::String.optional
    attribute :password_reset_date, Types::Strict::Time.optional
    attribute :assigned_groups, Types::Strict::Array.meta(desc: :yaml_array)
    attribute :roles, Types::Strict::Array.meta(desc: :yaml_array)
    attribute :active, Types::Strict::Bool
    attribute :file_access_token, Types::Strict::String.optional
    attribute :created_at, Types::Strict::Time
    attribute :updated_at, Types::Strict::Time
    attribute :person_authenticated_key, Types::Strict::String
    attribute :assigned_roles, Types::Strict::Array.meta(desc: :yaml_array)
    attribute :remember_token_digest , Types::Strict::String.optional
    attribute :user_options, Types::Strict::Array.meta(desc: :yaml_array)

    def pak
      person_authenticated_key
    end
  end


##
# ROM
##

  class Users < ROM::Relation[:sql]
    schema(:users, infer: false) do

      attribute :id, Types::Serial
      attribute :username, Types::Strict::String
      attribute :name, Types::Strict::String
      attribute :email, ::Types::Email
      attribute :password_digest, Types::Strict::String
      attribute :remember_token, Types::Strict::String.optional
      attribute :password_reset_token, Types::Strict::String.optional
      attribute :password_reset_date, Types::Strict::Time.optional
      attribute :assigned_groups, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :roles, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :active, Types::Strict::Bool
      attribute :file_access_token, Types::Strict::String.optional
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time
      attribute :person_authenticated_key, Types::Strict::String
      attribute :assigned_roles, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :remember_token_digest , Types::Strict::String.optional
      attribute :user_options, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)

      primary_key :id

    end

    auto_struct true

    # Define some composable, reusable query methods to return filtered
    # results from our database table. We'll use them in a moment.
    def by_id(id)
      where(id: id)
    end
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
  class Users < ROM::Repository[:users]
    struct_namespace Entity

    def all
      users.map_to(Entity::User).to_a
    end

    def query(conditions)
      users.where(conditions).map_to(Entity::User).to_a
    end

    def by_pak(pak)
      find_by(person_authenticated_key: pak)
    end

    def [](id)
      users.by_id(id).map_to(Entity::User).one
    end

    def by_id(id)
      users.by_id(id).one
    end

    def find_by(col_val_hash)
      users.where(col_val_hash).one
    end
  end
```


### Notes
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
It opens and extends the existing app name class.  `SknBase` is also the name of this apps main.  Helper files have the same behavior.

The assets plugin initially failed (HTTP-404) to send bootstrap.css at Roda V3.3.0.  Switched to 2.29.0 and it worked, tried 3.3.0 again and everything seems to work now!  Making this note in case the trouble shows again.
Asset Plugin Failure: Sending bottstrap.css with a 'Content-Type' eq 'text/html' 'Content-Length' eq '3045'; verus 'text/css' and 146K.

The PostgreSQL gem gave me trouble when brew updated to Version 10 of PostgreSQL, this solve the install problem.

```bash
$ bundle config build.pg --with-pg-config=/usr/local/Cellar/postgresql/10.1/bin/pg_config
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

```ruby
    File.join(Dir.pwd, "views")
```

#### Discover Warden inside app under Test
```ruby
     manager = app -- = Skn::SknBase.app
     manager = manager.instance_variable_get(:@app) while manager.class.name != 'Warden::Manager'

```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).