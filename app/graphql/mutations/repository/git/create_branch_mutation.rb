# frozen_string_literal: true

module Mutations
  module Repository
    module Git
      CreateBranchMutation = GraphQL::Field.define do
        type Types::Git::BranchType
        description 'Creates a new branch'

        argument :repositoryId, !types.ID do
          description 'The repository to create the branch in'
        end

        argument :name, !types.String do
          description 'The name of the branch'
        end

        argument :revision, !types.ID do
          description 'The revision the branch shall point to'
        end

        resource(lambda do |_root, arguments, _context|
          RepositoryCompound.find(slug: arguments['repositoryId'])
        end)

        resolve CreateBranchResolver.new
      end

      # GraphQL mutation to create a new branch
      class CreateBranchResolver
        def call(repository, arguments, context)
          repository.git.create_branch(arguments['name'], arguments['revision'])
        rescue Gitlab::Git::Repository::InvalidRef,
               Gitlab::Git::InvalidRefName => e
          context.add_error(GraphQL::ExecutionError.new(e.message))
        end
      end
    end
  end
end
