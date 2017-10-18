# frozen_string_literal: true

module Mutations
  module Organization
    RemoveOrganizationMemberMutation = GraphQL::Field.define do
      type types.Boolean
      description 'Removes a member from an organization'

      argument :organization, !types.ID do
        description 'The ID of the organization'
      end

      argument :member, !types.ID do
        description 'The ID of the member'
      end

      resource(lambda do |_root, arguments, _context|
        ::Organization.first(slug: arguments['organization'])
      end)

      authorize! :update, policy: :organization

      resolve RemoveOrganizationMemberResolver.new
    end

    # GraphQL mutation to remove a member from an organization
    class RemoveOrganizationMemberResolver
      def call(organization, arguments, _context)
        user = User.first(slug: arguments['member'])

        organization.remove_member(user)
        true
      end
    end
  end
end
