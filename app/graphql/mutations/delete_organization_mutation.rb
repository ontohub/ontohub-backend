# frozen_string_literal: true

module Mutations
  # GraphQL mutation to delete an organization
  class DeleteOrganizationMutation
    def call(_obj, args, _ctx)
      org = Organization.find(slug: args[:slug])
      org.destroy
      true
    end
  end
end
