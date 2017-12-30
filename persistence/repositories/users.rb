# File: ./persistence/repositories/users.rb
#
module Repositories

  class Users < ROM::Repository[:users]
    struct_namespace Entity

    def all
      users.map_to(Entity::User).to_a
    end

    def query(conditions)
      users.where(conditions).map_to(Entity::User).to_a
    end

    def [](id)
      by_id(id).map_to(Entity::User).one
    end

    def by_id(id)
      where(id: id)
    end

  end

end
