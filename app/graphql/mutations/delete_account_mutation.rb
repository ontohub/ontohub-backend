# frozen_string_literal: true

module Mutations
  # GraphQL mutation to delete an organization
  class DeleteAccountMutation
    def call(_obj, args, _ctx)
      user = ctx[:current_user]
      if user.valid_password?(args[:password])
        user.destroy
      end
      true
    end
  end
end
