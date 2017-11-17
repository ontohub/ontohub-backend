# frozen_string_literal: true

module Mutations
  module Repository
    module Git
      DeleteBranchMutation = GraphQL::Field.define do
        type types.Boolean
        description 'Creates a new branch'

        argument :repositoryId, !types.ID do
          description 'The repository to delete the branch from'
        end

        argument :name, !types.String do
          description 'The name of the branch'
        end

        resource!(lambda do |_root, arguments, _context|
          RepositoryCompound.first(slug: arguments['repositoryId'])
        end)

        not_found_unless :show

        authorize! :write, policy: :repository

        resolve DeleteBranchResolver.new
      end

      # GraphQL mutation to delete a branch
      class DeleteBranchResolver
        def call(repository, arguments, _context)
          repository.git.rm_branch(arguments['name'])
          true
        end
      end
    end
  end
end
