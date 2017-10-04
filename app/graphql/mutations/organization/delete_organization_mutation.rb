# frozen_string_literal: true

module Mutations
  module Organization
    DeleteOrganizationMutation = GraphQL::Field.define do
      type types.Boolean
      description <<~DESCRIPTION
        Deletes an organization.
        Returns `true` if it was successful and `null` if there was an error.
      DESCRIPTION

      argument :id, !types.ID, as: :slug do
        description 'The ID of the organization to delete'
      end

      resource!(lambda do |_root, arguments, _context|
        ::Organization.find(slug: arguments[:slug])
      end)

      authorize! :destroy

      resolve DeleteOrganizationResolver.new
    end

    # GraphQL mutation to delete an organization
    class DeleteOrganizationResolver
      def call(organization, _arguments, _context)
        organization.destroy
        true
      end
    end
  end
end
