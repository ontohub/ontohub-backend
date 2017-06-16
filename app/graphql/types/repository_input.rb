# frozen_string_literal: true

Types::RepositoryInput = GraphQL::InputObjectType.define do
  name 'RepositoryInput'

  argument :name, types.String
  argument :description, types.String
  argument :contentType, Types::RepositoryContent
  argument :publicAccess, types.Boolean
end
