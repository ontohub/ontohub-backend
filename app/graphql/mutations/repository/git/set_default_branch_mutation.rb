# frozen_string_literal: true

module Mutations
  module Repository
    module Git
      SetDefaultBranchMutation = GraphQL::Field.define do
        type Types::Git::BranchType
        description 'Sets the default branch'

        argument :repositoryId, !types.ID do
          description 'The repository to create the tag in'
        end

        argument :name, !types.String do
          description 'The name of the branch to make it the default'
        end

        resource!(lambda do |_root, arguments, _context|
          RepositoryCompound.find(slug: arguments['repositoryId'])
        end)

        resolve SetDefaultBranchResolver.new
      end

      # GraphQL mutation to create a new tag
      class SetDefaultBranchResolver
        def call(repository, arguments, context)
          arguments = arguments.to_h
          if repository.git.find_branch(arguments['name'])
            repository.git.default_branch = arguments['name']
            repository.git.find_branch(repository.git.default_branch)
          else
            message = %(The branch "#{arguments['name']}" does not exist.)
            context.add_error(GraphQL::ExecutionError.new(message))
            nil
          end
        end
      end
    end
  end
end
