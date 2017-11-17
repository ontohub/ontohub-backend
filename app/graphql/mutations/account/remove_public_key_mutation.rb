# frozen_string_literal: true

module Mutations
  module Account
    RemovePublicKeyMutation = GraphQL::Field.define do
      type types.Boolean
      description 'Removes an SSH public key'

      argument :name, !types.String do
        description 'The name of the public key to remove'
      end

      resource ->(_root, _arguments, context) { context[:current_user] },
               pass_through: true

      authorize!(lambda do |user, _arguments, context|
        UserPolicy.new(user, context[:current_user]).access_private_data?
      end)

      resolve RemovePublicKeyResolver.new
    end

    # GraphQL mutation to remove a public key
    class RemovePublicKeyResolver
      def call(user, arguments, _context)
        key = PublicKey.first(user_id: user.id, name: arguments[:name].strip)

        raise GraphQL::ExecutionError, 'Public key not found' unless key

        Sequel::Model.db.transaction do
          key.destroy
          AuthorizedKeysFile.write
        end

        true
      end
    end
  end
end
