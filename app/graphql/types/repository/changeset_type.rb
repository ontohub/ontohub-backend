# frozen_string_literal: true

Types::Repository::ChangesetType = GraphQL::InputObjectType.define do
  name 'RepositoryChangeset'
  description <<~DESCRIPTION
    Contains all fields of a repository that can be changed
  DESCRIPTION

  argument :description, types.String do
    description 'A short description of the repository'
  end
  argument :contentType, Types::Repository::ContentTypeEnum do
    as :content_type
    description 'The content type of the repository'
  end
  argument :visibility, Types::Repository::VisibilityEnum do
    description 'The visibility of the repository'
  end
end
