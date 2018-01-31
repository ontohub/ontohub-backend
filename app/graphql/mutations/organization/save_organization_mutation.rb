# frozen_string_literal: true

module Mutations
  module Organization
    SaveOrganizationMutation = GraphQL::Field.define do
      type Types::OrganizationType
      description 'Updates an organization'

      argument :id, !types.ID, as: :slug do
        description 'ID of the organization to update'
      end

      argument :data, !Types::Organization::ChangesetType do
        description 'Updated fields of the organization'
      end

      resource!(lambda do |_root, arguments, _context|
        ::Organization.first(slug: arguments[:slug])
      end)

      authorize! :update

      resolve SaveOrganizationResolver.new
    end

    # GraphQL mutation to update an organization
    class SaveOrganizationResolver
      def call(organization, arguments, _context)
        params = arguments[:data].to_h.compact
        params['description'] = nil if params['description'].empty?
        organization.update(params)
        IndexingJob.
          perform_later('class' => 'Organization', 'id' => organization.id)
        organization
      end
    end
  end
end
