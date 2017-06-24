# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update the current user account
  class SaveAccountMutation
    def call(_obj, args, ctx)
      user_args = args[:data].to_h.compact
      user = ctx[:current_user]
      user.update(user_args)
      user
    end
  end
end
