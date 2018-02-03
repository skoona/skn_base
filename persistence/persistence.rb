# File: ./persistence/persistence.rb
#

require 'psych'  # force JRuby to load it's version of the standard library
require "dry-types"
require "dry-monads"

unless defined?(JRuby)
  require "pg"
end

require "rom"
require "rom-sql"

module Types
  include Dry::Types.module

  Dry::Types.load_extensions(:maybe)

  Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  SerializedArrayRead = Types.Constructor(Types.Array(Types::Strict::String)) { |yaml_str| yaml_str.nil? ? [] : Psych.load(yaml_str).compact }
  SerializedArrayWrite = Types.Constructor(Types::Strict::String) { |ary_of_str| ary_of_str.nil? ? Psych.dump([])  : Psych.dump(ary_of_str.compact) }

end

require_relative 'entity/user'
require_relative 'relations/users'
require_relative 'repositories/users'

module Skn

# ## Initialize rom-rb
#
# rom-rb is built to be non-intrusive. When we initialize it here, all our
# relations and commands are bundled into a single container that we can
# inject into our app.
# ##

  db_config = ROM::Configuration.new(:sql, SknSettings.postgresql.url,
                       user: SknSettings.postgresql.username,
                       password: SknSettings.postgresql.password) do |config|

    config.gateways[:default].use_logger(Logging.logger['ROM'])

    config.register_relation Relations::Users
  end

  SknSettings.rom = ROM.container(db_config)

end
