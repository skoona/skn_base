# File ./strategy/entity/entities.rb
#
# Output Records via Mapping

module Entity

  class ProfileType < Dry::Struct
    attribute :id, Types::Strict::Int
    attribute :name, Types::String
    attribute :description, Types::String
  end

  class ContentProfileEntry < Dry::Struct
    attribute :id, Types::Strict::Int
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
    attribute :id, Types::Strict::Int
    attribute :person_authentication_key, Types::Strict::String
    attribute :authentication_provider, Types::Strict::String
    attribute :username, Types::Strict::String
    attribute :display_name, Types::Strict::String
    attribute :email, Types::Email
    attribute :created_at, Types::Strict::Time
    attribute :updated_at, Types::Strict::Time

    attribute :profile_types, Types.Constructor(ProfileType)
  end

  class ProfileEntry < Dry::Struct
    attribute :id, Types::Strict::Int
    attribute :person_authentication_key, Types::Strict::String
    attribute :authentication_provider, Types::Strict::String
    attribute :username, Types::Strict::String
    attribute :display_name, Types::Strict::String
    attribute :email, Types::Email
    attribute :created_at, Types::Strict::Time
    attribute :updated_at, Types::Strict::Time

    attribute :profile_types, Types.Constructor(ProfileType)
    attribute :content_profile_entries, Types::Array.of(ContentProfileEntry)
  end

end
