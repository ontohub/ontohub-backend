# frozen_string_literal: true

module Mutations
  # GraphQL mutation to create a new organization and
  # add the current user as a member
  class CreateOrganizationMutation
    def call(_obj, args, ctx)
      org_args = args[:data].to_h.merge(url_path_method: url_path_method)
      org = Organization.new(org_args)

      org.db.transaction do
        org.save
        org.add_member(ctx[:current_user])
      end
      org
    end

    private

    def url_path_method
      lambda do |resource|
        V2::OrganizationsController.resource_url_path(resource)
      end
    end
  end
end
