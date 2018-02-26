# frozen_string_literal: true

module Mutations
  module Organization
    CreateOrganizationMutation = GraphQL::Field.define do
      type Types::OrganizationType
      description 'Creates a new organization'

      argument :data, !Types::Organization::NewType do
        description 'The parameters of the new organization'
      end

      authorize! :create, policy: :organization

      resolve CreateOrganizationResolver.new
    end
    # GraphQL mutation to create a new organization and
    # add the current user as a member
    class CreateOrganizationResolver
      def call(_root, arguments, context)
        params = arguments[:data].to_h
        organization = ::Organization.new(params)

        organization.db.transaction do
          organization.save
          organization.add_member(context[:current_user])
        end
        IndexingJob.
          perform_later('class' => 'Organization', 'id' => organization.id)
        organization
      end
    end
  end
end
