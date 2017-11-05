# frozen_string_literal: true

module Mutations
  module Account
    AddPublicKeyMutation = GraphQL::Field.define do
      type Types::PublicKeyType
      description 'Adds a new SSH public key'

      argument :key, !types.String do
        description 'The public key to add'
      end

      resource ->(_root, _arguments, context) { context[:current_user] },
               pass_through: true

      authorize!(lambda do |user, _arguments, context|
        UserPolicy.new(user, context[:current_user]).access_private_data?
      end)

      resolve AddPublicKeyResolver.new
    end

    # GraphQL mutation to add a public key
    class AddPublicKeyResolver
      def call(user, arguments, _context)
        key_with_comment = arguments[:key].split(' ')
        key = key_with_comment.take(2).join(' ').strip
        name = key_with_comment.drop(2).join(' ').strip

        Sequel::Model.db.transaction do
          pub_key = user.add_public_key(PublicKey.new(key: key,
                                                      name: name,
                                                      user: user))

          AuthorizedKeysFile.write
          pub_key
        end
      end
    end
  end
end
