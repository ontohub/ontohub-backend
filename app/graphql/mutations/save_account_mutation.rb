# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update the current user account
  class SaveAccountMutation
    def call(user, arguments, _context)
      params = arguments[:data].to_h.compact
      user.update(params) if user.valid_password?(arguments[:password])
      user
    end
  end
end
