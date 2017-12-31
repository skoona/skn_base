# File: ./persistence/relations/users.rb
#

# Define a canonical schema for this relation. This will be used when we
# use commands to make changes to our data. It ensures that only
# appropriate attributes are written through to the database table.

module Relations

  class Users < ROM::Relation[:sql]
    schema(:users, infer: false) do

      attribute :id, Types::Serial
      attribute :username, Types::Strict::String
      attribute :name, Types::Strict::String
      attribute :email, ::Types::Email
      attribute :password_digest, Types::Strict::String
      attribute :remember_token, Types::Strict::String.optional
      attribute :password_reset_token, Types::Strict::String.optional
      attribute :password_reset_date, Types::Strict::Time.optional
      attribute :assigned_groups, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :roles, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :active, Types::Strict::Bool
      attribute :file_access_token, Types::Strict::String.optional
      attribute :created_at, Types::Strict::Time
      attribute :updated_at, Types::Strict::Time
      attribute :person_authenticated_key, Types::Strict::String
      attribute :assigned_roles, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)
      attribute :remember_token_digest , Types::Strict::String.optional
      attribute :user_options, ::Types::SerializedArrayWrite.meta(desc: :yaml_array), read: ::Types::SerializedArrayRead.meta(desc: :yaml_array)

      primary_key :id

    end

    auto_struct true

    # Define some composable, reusable query methods to return filtered
    # results from our database table. We'll use them in a moment.
    def by_pak(pak)
      where(person_authenticated_key: pak)
    end

    def by_id(id)
      where(id: id)
    end

    def find_by(col, val)
      where(col => val)
    end

    #Security Related methods
    # def encrypt_password
    #   self.password_digest = BCrypt::Password.create(password)
    # end
    #
    # def self.authenticate(email, password)
    #   user = filter(Sequel.function(:lower, :email) => Sequel.function(:lower, email)).first
    #   user && user.valid_password?(password) ? user : nil
    # end
    #
    # def valid_password?(password)
    #   BCrypt::Password.new(self.password_hash) == password
    # end
  end

end