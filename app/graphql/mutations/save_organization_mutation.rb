# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update an organization
  class SaveOrganizationMutation
    def call(organization, arguments, _context)
      params = arguments[:data].to_h.compact
      params['description'] = nil if params['description'].empty?
      organization.update(params)
      organization
    end
  end
end
