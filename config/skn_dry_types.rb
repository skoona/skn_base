# File: ./config/skn_dry_types.rb

require 'psych'

module Types
  include Dry::Types.module

  Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  SerializedArrayRead = Types.Constructor(Types.Array(String)) { |yaml_str| Psych.load(yaml_str) }
  SerializedArrayWrite = Types.Constructor(String) { |ary_of_str| Psych.dump(ary_of_str) }

  # SerializedArrayRead = Types.Constructor(Types.Array(Types::Strict::String)) { |yaml_str| Psych.load(yaml_str) }
  # SerializedArrayWrite = Types.Constructor(Types::Strict::String) { |ary_of_str| Psych.dump(ary_of_str) }
  # SerialPrimaryKey = Types.Constructor(Types::Strict::Int.meta(primary_key: true))
  # SerialPrimaryKey = Types.Constructor(Int.constrained(gt: 0).meta(primary_key: true))

end
