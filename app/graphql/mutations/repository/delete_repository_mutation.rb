# frozen_string_literal: true

module Mutations
  module Repository
    DeleteRepositoryMutation = GraphQL::Field.define do
      type types.Boolean
      description 'Deletes a repository'

      argument :id, !types.ID, as: :slug do
        description 'The ID of the repository to delete'
      end

      resource!(lambda do |_root, arguments, _context|
        RepositoryCompound.first(slug: arguments[:slug])
      end)

      not_found_unless :show

      authorize! :destroy

      resolve DeleteRepositoryResolver.new
    end

    # GraphQL mutation to delete a repository
    class DeleteRepositoryResolver
      def call(repository, _arguments, _context)
        repository.destroy
        true
      end
    end
  end
end
