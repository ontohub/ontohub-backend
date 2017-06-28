# frozen_string_literal: true

module Mutations
  # GraphQL mutation to create a new organization and
  # add the current user as a member
  class CreateOrganizationMutation
    def call(_root, arguments, context)
      params = arguments[:data].to_h.
        merge(url_path_method: ModelURLPath.organization)
      organization = Organization.new(params)

      organization.db.transaction do
        organization.save
        organization.add_member(context[:current_user])
      end
      organization
    end
  end
end
