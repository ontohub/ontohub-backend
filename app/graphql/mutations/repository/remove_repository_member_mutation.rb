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
        user = User.first(slug: arguments['member'])

        repository.remove_member(user)
        true
      end
    end
  end
end
