# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update an organization
  class SaveOrganizationMutation
    def call(_obj, args, _ctx)
      org_args = args[:data].to_h.compact
      org = Organization.find(slug: args[:slug])
      org.update(org_args)
      org
    end
  end
end
