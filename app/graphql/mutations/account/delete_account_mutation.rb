# frozen_string_literal: true

module Mutations
  module Account
    DeleteAccountMutation = GraphQL::Field.define do
      type types.Boolean
      description <<~DESCRIPTION
        Deletes the account of the currently signed in user.
        Returns `true` if it was successful and `null` if there was an error.
      DESCRIPTION

      argument :password, !types.String do
        description 'Password of the current user to confirm the deletion'
      end

      resource ->(_root, _arguments, context) { context[:current_user] },
               pass_through: true

      authorize! :destroy, policy: :account

      resolve DeleteAccountResolver.new
    end

    # GraphQL mutation to delete the current user account
    class DeleteAccountResolver
      def call(user, arguments, _context)
        user.destroy if user.valid_password?(arguments[:password])
        IndexingJob.
          perform_later('class' => 'User', 'id' => resource.id)
        true
      end
    end
  end
end
