# frozen_string_literal: true

module Mutations
  module Repository
    module Git
      DeleteTagMutation = GraphQL::Field.define do
        type types.Boolean
        description 'Creates a new tag'

        argument :repositoryId, !types.ID do
          description 'The repository to delete the tag from'
        end

        argument :name, !types.String do
          description 'The name of the tag'
        end

        resource(lambda do |_root, arguments, _context|
          RepositoryCompound.find(slug: arguments['repositoryId'])
        end)

        resolve DeleteTagResolver.new
      end

      # GraphQL mutation to delete a tag
      class DeleteTagResolver
        def call(repository, arguments, _context)
          repository.git.rm_tag(arguments['name'])
          true
        end
      end
    end
  end
end
