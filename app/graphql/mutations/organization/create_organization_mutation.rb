# frozen_string_literal: true

module Mutations
  module Organization
    CreateOrganizationMutation = GraphQL::Field.define do
      type Types::OrganizationType
      description 'Creates a new organization'

      argument :data, !Types::Organization::NewType do
        description 'The parameters of the new organization'
      end

      resolve CreateOrganizationResolver.new
    end
    # GraphQL mutation to create a new organization and
    # add the current user as a member
    class CreateOrganizationResolver
      def call(_root, arguments, context)
        params = arguments[:data].to_h.
          merge(url_path_method: ModelURLPath.organization)
        organization = ::Organization.new(params)

        organization.db.transaction do
          organization.save
          organization.add_member(context[:current_user])
        end
        organization
      end
    end
  end
end