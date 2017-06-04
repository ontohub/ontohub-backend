# frozen_string_literal: true

Types::Repository = GraphQL::ObjectType.define do
  name 'Repository'
  field :id, !types.ID do
    description 'ID of the repository'
    resolve ->(obj, _args, _ctx) { obj.slug }
  end
  field :owner, !Types::OrganizationalUnit
  field :description, !types.String
  field :contentType, !Types::RepositoryContent do
    resolve ->(obj, _args, _ctx) { obj.content_type }
  end
  field :publicAccess, !types.Boolean do
    resolve ->(obj, _args, _ctx) { obj.public_access }
  end
end
