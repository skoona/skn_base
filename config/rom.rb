# File: ./config/rom.rb
#

require_relative 'skn_dry_types'
require 'entity/profile'
require 'entity/user'
require 'relations/profiles'
require 'relations/users'
require 'repositories/profiles'
require 'repositories/users'

module Skn

# ## Initialize rom-rb
#
# rom-rb is built to be non-intrusive. When we initialize it here, all our
# relations and commands are bundled into a single container that we can
# inject into our app.
# ##

  db_config = ROM::Configuration.new(:sql, SknSettings.postgresql.url,
                       user: SknSettings.postgresql.user,
                       password: SknSettings.postgresql.password) do |config|

    config.gateways[:default].use_logger(Logging.logger['ROM'])

    config.register_relation Relations::ProfileTypes
    config.register_relation Relations::ContentProfilesEntries
    config.register_relation Relations::ContentProfileEntries
    config.register_relation Relations::ContentProfiles
    config.register_relation Relations::Users
  end

  SknSettings.rom = ROM.container(db_config)

end
