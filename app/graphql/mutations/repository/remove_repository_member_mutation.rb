# frozen_string_literal: true

module Mutations
  module Repository
    RemoveRepositoryMemberMutation = GraphQL::Field.define do
      type types.Boolean
      description 'Removes a member from a repository'

      argument :repository, !types.ID do
        description 'The ID of the repository'
      end

      argument :member, !types.ID do
        description 'The ID of the member'
      end

      resource!(lambda do |_root, arguments, _context|
        RepositoryCompound.first(slug: arguments['repository'])
      end)

      not_found_unless :show

      authorize! :update, policy: :repository

      resolve RemoveRepositoryMemberResolver.new
    end

    # GraphQL mutation to remove a member from a repository
    class RemoveRepositoryMemberResolver
      def call(repository, arguments, _context)
        member = repository.members_dataset.first(slug: arguments['member'])
        return false unless member

        repository.remove_member(member)
        true
      end
    end
  end
end
