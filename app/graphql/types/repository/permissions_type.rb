# frozen_string_literal: true

Types::Repository::PermissionsType = GraphQL::ObjectType.define do
  name 'RepositoryPermissions'
  description 'Holds permission information for an repository'

  field :role, !Types::Repository::RoleEnum do
    description "The user's role in the repository"

    resolve(lambda do |repository, _arguments, context|
      return 'admin' if repository.owner.id == context[:current_user].id

      RepositoryMembership.first(repository_id: repository.id,
                                 member_id: context[:current_user].id).role
    end)
  end
end
