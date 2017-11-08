# frozen_string_literal: true

module Mutations
  module Repository
    AddUrlMappingMutation = GraphQL::Field.define do
      type Types::Repository::UrlMappingType
      description 'Adds a new URL Mapping'

      argument :repositoryId, !types.ID do
        description 'The ID of the repository'
      end
      argument :source, !types.String do
        description 'The search substring of the URL'
      end
      argument :target, !types.String do
        description 'The replacement string of the URL'
      end

      resource!(lambda do |_root, arguments, _context|
        RepositoryCompound.first(slug: arguments[:repositoryId])
      end)

      not_found_unless :show

      authorize! :update

      resolve AddUrlMappingResolver.new
    end

    # GraphQL mutation to add new URL mappings
    class AddUrlMappingResolver
      def call(repository, arguments, _context)
        UrlMapping.create(repository: repository, source: arguments[:source],
                          target: arguments[:target])
      end
    end
  end
end
