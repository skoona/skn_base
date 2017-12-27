# File: ./config/rom.rb
#

$rom = ROM.container(:sql, SknSettings.postgresql.url,
                     user: SknSettings.postgresql.user,
                     password: SknSettings.postgresql.password
) do |config|
  config.relation(:content_profiles) do
    schema(infer: true) do
      associations do
        belongs_to :profile_type
        has_many   :content_profile_entries, through: :content_profiles_entries
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

module Repositories

  class ProfileRepository < ROM::Repository[:content_profiles]
    def by_id(id)
      content_profiles.where(id: id).combine(:profile_type).one
    end
    def entry_info
    end
  end

  # Todo: Users aggregate

end
