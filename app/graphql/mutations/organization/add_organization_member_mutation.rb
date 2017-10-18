# frozen_string_literal: true

module Mutations
  module Organization
    AddOrganizationMemberMutation = GraphQL::Field.define do
      type Types::Organization::MembershipType
      description <<~DESCRIPTION
        Adds a new member to an organization or updates an existing membership
      DESCRIPTION

      argument :organization, !types.ID do
        description 'The ID of the organization'
      end

      argument :member, !types.ID do
        description 'The ID of the member'
      end

      argument :role, !Types::Organization::RoleEnum do
        description 'The role in the organization'
      end

      resource(lambda do |_root, arguments, _context|
        ::Organization.first(slug: arguments['organization'])
      end)

      authorize! :update, policy: :organization

      resolve AddOrganizationMemberResolver.new
    end

    # GraphQL mutation to add a new member to an organization
    class AddOrganizationMemberResolver
      def call(organization, arguments, _context)
        user = User.first(slug: arguments['member'])
        role = arguments['role']

        organization.add_member(user, role)
      end
    end
  end
end
