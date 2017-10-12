# frozen_string_literal: true

Types::Repository::MembershipType = GraphQL::ObjectType.define do
  name 'RepositoryMembership'
  description 'The membership of a user in a repository'

  field :member, !Types::UserType do
    description 'The member'
  end

  field :repository, !Types::RepositoryType do
    description 'The repository'
  end

  field :role, !Types::Repository::RoleEnum do
    description "The member's role in the repository"
  end
end
