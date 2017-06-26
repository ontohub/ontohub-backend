# frozen_string_literal: true

module Mutations
  # GraphQL mutation to delete an organization
  class DeleteOrganizationMutation
    def call(org, _args, _ctx)
      org.destroy
      true
    end
  end
end
