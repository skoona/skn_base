# File: ./config/rom.rb
#

require 'rom'

require_relative 'skn_dry_types'
require 'entity/entities'
require 'relations/relations'
require 'repositories/repositories'

module Skn

# ## Initialize rom-rb
#
# rom-rb is built to be non-intrusive. When we initialize it here, all our
# relations and commands are bundled into a single container that we can
# inject into our app.
#
# Configure rom-rb to use an in-memory SQLite database via its SQL adapter,
# register our articls relation, then build and finalize the persistence
# container.

#   config = ROM::Configuration.new(:sql, "sqlite::memory")
#   config.register_relation Relations::Articles
#   container = ROM.container(config)

  db_config = ROM::Configuration.new(:sql, SknSettings.postgresql.url,
                       user: SknSettings.postgresql.user,
                       password: SknSettings.postgresql.password) do |config|

    config.gateways[:default].use_logger(Logging.logger['ROM'])

    config.register_relation Relations::ProfileTypes
    config.register_relation Relations::ContentProfilesEntries
    config.register_relation Relations::ContentProfileEntries
    config.register_relation Relations::ContentProfiles
  end

  SknSettings.rom = ROM.container(db_config)

end
