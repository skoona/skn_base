# File: ./config/rom.rb
#
module Skn

  SknSettings.rom = ROM.container(:sql, SknSettings.postgresql.url,
                       user: SknSettings.postgresql.user,
                       password: SknSettings.postgresql.password) do |config|

    config.relation(:content_profiles) do
      schema(infer: true) do
        associations do
          belongs_to :profile_type
          has_many   :content_profile_entries, through: :content_profiles_entries, view: :ordered
        end
      end
      auto_struct true
    end

    config.relation(:content_profile_entries) do
      schema(infer: true) do
        associations do
          has_many :content_profiles, through: :content_profiles_entries
        end
      end

      view(:ordered) do
        schema do
          append(relations[:content_profiles_entries][:content_profile_entry_id])
        end

        relation do
          where(content_profile_id: :content_profile_id).order(:content_profile_entry_id)
        end
      end

      auto_struct true
    end

    config.relation(:profile_types) do
      schema(infer: true)
      auto_struct true
    end

    config.relation(:content_profiles_entries) do
      schema(infer: true) do
        associations do
          belongs_to :content_profiles
          belongs_to :content_profile_entries
        end
      end
    end

  end

end

require 'persistence/repositories'
