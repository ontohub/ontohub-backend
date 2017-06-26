# frozen_string_literal: true

module Mutations
  # GraphQL mutation to update an organization
  class SaveOrganizationMutation
    def call(org, args, _ctx)
      org_args = args[:data].to_h.compact
      org.update(org_args)
      org
    end
  end
end
