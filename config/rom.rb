# File: ./config/rom.rb
#

module Skn

  SknSettings.rom = ROM.container(:sql, SknSettings.postgresql.url,
                       user: SknSettings.postgresql.user,
                       password: SknSettings.postgresql.password) do |config|

    config.gateways[:default].use_logger(Logging.logger['ROM'])

    config.relation(:content_profiles) do
      schema(infer: false) do
        attribute :id, Types::Strict::Int.meta(primary_key: true)
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

      struct_namespace Skn::Entities
      auto_struct true
    end

    config.relation(:content_profile_entries) do
      schema(infer: false) do
        attribute :id, Types::Strict::Int.meta(primary_key: true)
        attribute :topic_value, Types::ARSerializedWrite.meta(desc: :yaml_array), read: Types::ARSerializedRead.meta(desc: :yaml_array)
        attribute :topic_type, Types::Strict::String
        attribute :topic_type_description, Types::Strict::String
        attribute :content_value, Types::ARSerializedWrite.meta(desc: :yaml_array), read: Types::ARSerializedRead.meta(desc: :yaml_array)
        attribute :content_type, Types::Strict::String
        attribute :content_type_description, Types::Strict::String
        attribute :description, Types::Strict::String
        attribute :created_at, Types::Strict::Time
        attribute :updated_at, Types::Strict::Time

        primary_key :id
      end

      # view(:ordered) do
      #   schema do
      #     append(relations[:content_profiles_entries][:content_profile_entry_id])
      #   end
      #
      #   relation do
      #     where(content_profile_id: :content_profile_id).order(:content_profile_entry_id)
      #   end
      # end

      struct_namespace Skn::Entities
      auto_struct true
    end

    config.relation(:profile_types) do
      schema(infer: false) do
        attribute :id, Types::Strict::Int.meta(primary_key: true)
        attribute :name, Types::Strict::String
        attribute :description, Types::Strict::String
        attribute :created_at, Types::Strict::Time
        attribute :updated_at, Types::Strict::Time

        primary_key :id
      end

      struct_namespace Skn::Entities
      auto_struct true
    end

    config.relation(:content_profiles_entries) do
      schema(infer: false) do

        attribute :id, Types::Strict::Int.meta(primary_key: true)
        attribute :content_profile_id, Types::Int.meta(foreign_key: true, relation: :content_profiles)
        attribute :content_profile_entry_id, Types::Int.meta(foreign_key: true, relation: :content_profile_entries)

        primary_key :id

        associations do
          belongs_to :content_profiles
          belongs_to :content_profile_entries
        end
      end
    end

  end

end

require 'persistence/repositories'
