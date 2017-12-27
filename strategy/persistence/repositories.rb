module Skn
  module Persistence

    class Profiles < ROM::Repository[:content_profiles]

      def entry_info_by_name(value)
        aggregate(:content_profile_entries).where(username: value).combine(:profile_type).one
      end

      def query(conditions)
        content_profiles.where(conditions)
      end

      def by_id(id)
        content_profiles.where(id: id).combine(:profile_type).one
      end

    end

    # Todo: Users aggregate

  end
end
