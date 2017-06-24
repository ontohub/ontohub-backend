# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update the current user account
  class SaveAccountMutation
    def call(_obj, args, ctx)
      user_args = args[:data].to_h.compact
      user = ctx[:current_user]
      if user.valid_password?(args[:password])
        user.update(user_args)
      end
      user
    end
  end
end
