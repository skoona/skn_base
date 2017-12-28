# File: ./strategy/skn_dry_types.rb

module Types
  include Dry::Types.module

  Email = String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
  ARSerializedRead = Types.Constructor(Types.Array(Types::Strict::String)) { |yaml_str| Psych.load(yaml_str) }
  ARSerializedWrite = Types.Constructor(Types::Strict::String) { |ary_of_str| Psych.dump(ary_of_str) }

end
