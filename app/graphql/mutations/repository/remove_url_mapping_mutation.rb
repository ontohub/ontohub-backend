# frozen_string_literal: true

module Mutations
  module Repository
    RemoveUrlMappingMutation = GraphQL::Field.define do
      type types.Boolean
      description 'Removes an URL Mapping'

      argument :repositoryId, !types.ID do
        description 'The ID of the repository in which the URL mapping exits'
      end

      argument :urlMappingId, !types.ID do
        description 'The ID of the URL mapping'
      end

      resource!(lambda do |_root, arguments, _context|
        ::Repository.first(slug: arguments[:repositoryId])
      end)

      authorize! :update

      resolve RemoveUrlMappingResolver.new
    end

    # GraphQL mutation to add new URL mappings
    class RemoveUrlMappingResolver
      def call(repository, arguments, context)
        url_mapping = repository.url_mappings_dataset.
          first(id: arguments[:urlMappingId])
        if url_mapping.nil?
          context.add_error(GraphQL::ExecutionError.new('resource not found'))

          false
        else
          url_mapping.destroy

          true
        end
      end
    end
  end
end
