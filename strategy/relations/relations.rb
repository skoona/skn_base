# File: ./strategy/relations/content_profiles.rb
#

# Define a canonical schema for this relation. This will be used when we
# use commands to make changes to our data. It ensures that only
# appropriate attributes are written through to the database table.

module Relations

  class ProfileType < ROM::Relation[:sql]
    schema(:profile_types, infer: false) do

      attribute :id, Types::SerialPrimaryKey
      attribute :name, Types::Strict::String
      attribute :description, Types::Strict::String
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time

      primary_key :id
    end

    struct_namespace Entity
    auto_struct true

    def by_id(id)
      where(id: id)
    end
  end

  # Join Table
  class ContentProfilesEntry < ROM::Relation[:sql]
    schema(:content_profiles_entries, infer: false) do

      attribute :id, Types::SerialPrimaryKey
      attribute :content_profile_id, Types::Int.meta(foreign_key: true, relation: :content_profiles)
      attribute :content_profile_entry_id, Types::Int.meta(foreign_key: true, relation: :content_profile_entries)

      primary_key :id

      associations do
        belongs_to :content_profiles
        belongs_to :content_profile_entries
      end
    end
  end

  class ContentProfileEntry < ROM::Relation[:sql]
    schema(:content_profile_entries, infer: false) do

      attribute :id, Types::SerialPrimaryKey
      attribute :topic_value, Types::SerializedArrayWrite.meta(desc: :yaml_array), read: Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :topic_type, Types::Strict::String
      attribute :topic_type_description, Types::Strict::String
      attribute :content_value, Types::SerializedArrayWrite.meta(desc: :yaml_array), read: Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :content_type, Types::Strict::String
      attribute :content_type_description, Types::Strict::String
      attribute :description, Types::Strict::String
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time

      primary_key :id
    end

    struct_namespace Entity
    auto_struct true

    def by_id(id)
      where(id: id)
    end
  end

  class ContentProfile < ROM::Relation[:sql]
    schema(:content_profiles, infer: false) do

      attribute :id, Types::SerialPrimaryKey
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

    struct_namespace Entity
    auto_struct true

    # Define some composable, reusable query methods to return filtered
    # results from our database table. We'll use them in a moment.
    def by_pak(pak)
      where(person_authentication_key: pak)
    end

    def by_id(id)
      where(id: id)
    end
  end

end
