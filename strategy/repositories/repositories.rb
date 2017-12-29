# File: ./strategy/repositories/repositories.rb
#
module Repositories

  class Profiles < ROM::Repository[:content_profiles]

    def entry_infos
      aggregate(:profile_types, :content_profile_entries).map_to(Entity::ProfileEntry).to_a
    end

    def entry_info_by_pak(pak)
      aggregate(:profile_types, :content_profile_entries).where( person_authentication_key: pak ).map_to(Entity::ProfileEntry).one
    end

    def query(conditions)
      content_profiles.where(conditions).map_to(Entity::ContentProfile).to_a
    end

    def [](id)
      by_id(id).combine(:profile_types).map_to(Entity::ContentProfile).one
    end

    # def [](id)
    #   aggregate(:categories)
    #       .by_id(id)
    #       .as(Article)
    #       .one!
    # end
  end

  # Todo: Users aggregate

end
