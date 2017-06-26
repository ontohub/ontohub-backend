# frozen_string_literal: true

module Mutations
  # GraphQL mutation to delete an organization
  class DeleteAccountMutation
    def call(user, args, _ctx)
      user.destroy if user.valid_password?(args[:password])
      true
    end
  end
end
