# frozen_string_literal: true

module Mutations
  module Account
    RemovePublicKeyMutation = GraphQL::Field.define do
      type types.Boolean
      description 'Removes an SSH public key'

      argument :name, !types.String do
        description 'The name of the public key to remove'
      end

      resolve RemovePublicKeyResolver.new
    end

    # GraphQL mutation to remove a public key
    class RemovePublicKeyResolver
      def call(_root, arguments, context)
        user = context[:current_user]
        key = PublicKey.find(user_id: user.id, name: arguments[:name].strip)

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
