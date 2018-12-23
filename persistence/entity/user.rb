# File ./persistence/entity/user.rb
#
# Output Records via Mapping

module Entity

  class User < ROM::Struct

    def pak
      person_authentication_key
    end
  end

end
