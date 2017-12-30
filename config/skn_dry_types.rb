# File: ./config/skn_dry_types.rb

require 'psych'  # force JRuby to load it's version of the standard library

module Types
  include Dry::Types.module

  Dry::Types.load_extensions(:maybe)

  Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  SerializedArrayRead = Types.Constructor(Types.Array(Types::Strict::String)) { |yaml_str| yaml_str.nil? ? [] : Psych.load(yaml_str).compact }
  SerializedArrayWrite = Types.Constructor(Types::Strict::String) { |ary_of_str| ary_of_str.nil? ? Psych.dump([])  : Psych.dump(ary_of_str.compact) }

  # SerializedArrayRead = Types.Constructor(Types.Array(Types::Strict::String)) { |yaml_str| Psych.load(yaml_str) }
  # SerializedArrayWrite = Types.Constructor(Types::Strict::String) { |ary_of_str| Psych.dump(ary_of_str) }
  # SerialPrimaryKey = Types.Constructor(Types::Strict::Int.meta(primary_key: true))
  # SerialPrimaryKey = Int.constrained(gt: 0).meta(primary_key: true)

end
