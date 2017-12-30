# File: ./strategy/relations/profiles.rb
#

# Define a canonical schema for this relation. This will be used when we
# use commands to make changes to our data. It ensures that only
# appropriate attributes are written through to the database table.

module Relations

  class ProfileTypes < ROM::Relation[:sql]
    schema(:profile_types, infer: false) do

      attribute :id, Types::Serial #PrimaryKey
      attribute :name, Types::Strict::String
      attribute :description, Types::Strict::String
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time

      primary_key :id
    end

    auto_struct true

    def by_id(id)
      where(id: id)
    end
    def by_name(val)
      where(name: val)
    end
  end

  # Join Table
  class ContentProfilesEntries < ROM::Relation[:sql]
    schema(:content_profiles_entries, infer: false) do

      attribute :id, Types::Serial #PrimaryKey
      attribute :content_profile_id, Types::ForeignKey(:content_profiles)              #Types::Int.meta(foreign_key: true, relation: :content_profiles)
      attribute :content_profile_entry_id, Types::ForeignKey(:content_profile_entries) #Types::Int.meta(foreign_key: true, relation: :content_profile_entries)

      primary_key :id
      # foreign_key :content_profiles
      # foreign_key :content_profile_entries

      associations do
        belongs_to :content_profiles
        belongs_to :content_profile_entries
      end
    end
  end

  class ContentProfileEntries < ROM::Relation[:sql]
    schema(:content_profile_entries, infer: false) do

      attribute :id, Types::Serial #PrimaryKey
      attribute :topic_value, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :topic_type, Types::Strict::String
      attribute :topic_type_description, Types::Strict::String
      attribute :content_value, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :content_type, Types::Strict::String
      attribute :content_type_description, Types::Strict::String
      attribute :description, Types::Strict::String
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time

      primary_key :id
    end

    auto_struct true

    def by_id(id)
      where(id: id)
    end
    def by_topic_type(val)
      where(topic_type: val)
    end
    def by_content_type(val)
      where(content_type: val)
    end
  end

  class ContentProfiles < ROM::Relation[:sql]
    schema(:content_profiles, infer: false) do

      attribute :id, Types::Serial #PrimaryKey
      attribute :person_authentication_key, Types::Strict::String
      attribute :profile_type_id, Types::ForeignKey(:profile_types) #               Types::Int.meta(foreign_key: true, relation: :profile_types)
      attribute :authentication_provider, Types::Strict::String
      attribute :username, Types::Strict::String
      attribute :display_name, Types::Strict::String
      attribute :email, ::Types::Email
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time

      primary_key :id
      # foreign_key(:profile_types)

      associations do
        belongs_to :profile_types
        has_many   :content_profile_entries, through: :content_profiles_entries #, view: :ordered
      end
    end

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
