# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update the current user account
  class SaveAccountMutation
    def call(user, args, _ctx)
      user_args = args[:data].to_h.compact
      user.update(user_args) if user.valid_password?(args[:password])
      user
    end
  end
end
