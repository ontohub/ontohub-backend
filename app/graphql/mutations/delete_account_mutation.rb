# frozen_string_literal: true

module Mutations
  # GraphQL mutation to delete the current user account
  class DeleteAccountMutation
    def call(user, arguments, _context)
      user.destroy if user.valid_password?(arguments[:password])
      true
    end
  end
end
