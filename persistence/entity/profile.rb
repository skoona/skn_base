# File ./persistence/entity/profile.rb
#
# Output Records via Mapping

module Entity

  class ProfileType < ROM::Struct
    attribute :id, Types::Strict::Int
    attribute :name, Types::Strict::String
    attribute :description, Types::Strict::String
  end

  class ContentProfileEntry < ROM::Struct
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

  class ContentProfile < ROM::Struct
    attribute :id, Types::Strict::Int
    attribute :person_authentication_key, Types::Strict::String
    attribute :authentication_provider, Types::Strict::String
    attribute :username, Types::Strict::String
    attribute :display_name, Types::Strict::String
    attribute :email, Types::Email
    attribute :created_at, Types::Strict::Time
    attribute :updated_at, Types::Strict::Time

    attribute :profile_types, ProfileType

    def profile_name
      profile_types.name
    end
    def profile_type
      profile_type
    end
  end

  class ProfileEntry < ROM::Struct
    attribute :id, Types::Strict::Int
    attribute :person_authentication_key, Types::Strict::String
    attribute :authentication_provider, Types::Strict::String
    attribute :username, Types::Strict::String
    attribute :display_name, Types::Strict::String
    attribute :email, Types::Email
    attribute :created_at, Types::Strict::Time
    attribute :updated_at, Types::Strict::Time

    attribute :profile_types, ProfileType
    attribute :content_profile_entries, Types::Array.of(ContentProfileEntry)

    def profile_name
      profile_types.name
    end
    def profile_type
      profile_type
    end
    def entries
      content_profile_entries
    end
  end

end
