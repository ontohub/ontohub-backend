# frozen_string_literal: true

module Mutations
  module Repository
    AddRepositoryMemberMutation = GraphQL::Field.define do
      type Types::Repository::MembershipType
      description <<~DESCRIPTION
        Adds a new member to a repository or updates an existing membership
      DESCRIPTION

      argument :repository, !types.ID do
        description 'The ID of the repository'
      end

      argument :member, !types.ID do
        description 'The ID of the member'
      end

      argument :role, !Types::Repository::RoleEnum do
        description 'The role in the repository'
      end

      resource!(lambda do |_root, arguments, _context|
        RepositoryCompound.first(slug: arguments['repository'])
      end)

      not_found_unless :show

      authorize! :update, policy: :repository

      resolve AddRepositoryMemberResolver.new
    end

    # GraphQL mutation to add a new member to a repository
    class AddRepositoryMemberResolver
      def call(repository, arguments, _context)
        user = User.first(slug: arguments['member'])
        role = arguments['role']

        repository.add_member(user, role)
      end
    end
  end
end
