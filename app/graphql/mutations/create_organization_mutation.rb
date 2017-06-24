# frozen_string_literal: true

module Mutations
  # GraphQL mutation to create a new organization and
  # add the current user as a member
  module CreateOrganizationMutation
    def self.call(_obj, args, ctx)
      org_args = args[:data].to_h.merge(url_path_method: url_path_method)
      org = Organization.new(org_args)

      org.db.transaction do
        org.save
        org.add_member(ctx[:current_user])
      end
      org
    rescue Sequel::ValidationFailed => error
      raise GraphQL::ExecutionError, error.message
    end

    def self.url_path_method
      lambda do |resource|
        V2::OrganizationsController.resource_url_path(resource)
      end
    end
  end
end
