# frozen_string_literal: true

module Mutations
  # GraphQL mutation to delete an organization
  class DeleteAccountMutation
    def call(_obj, args, ctx)
      user = ctx[:current_user]
      user.destroy if user.valid_password?(args[:password])
      true
    end
  end
end
