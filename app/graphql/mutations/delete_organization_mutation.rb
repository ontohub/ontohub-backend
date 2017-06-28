# frozen_string_literal: true

module Mutations
  # GraphQL mutation to delete an organization
  class DeleteOrganizationMutation
    def call(organization, _arguments, _context)
      organization.destroy
      true
    end
  end
end
