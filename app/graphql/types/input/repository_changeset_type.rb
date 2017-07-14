# frozen_string_literal: true

Types::Input::RepositoryChangesetType = GraphQL::InputObjectType.define do
  name 'RepositoryChangeset'
  description <<~DESCRIPTION
    Contains all fields of a repository that can be changed
  DESCRIPTION

  argument :description, types.String do
    description 'A short description of the repository'
  end
  argument :contentType, Types::RepositoryContentTypeEnum, as: :content_type do
    description 'The content type of the repository'
  end
  argument :visibility, Types::RepositoryVisibilityEnum do
    description 'The visibility of the repository'
  end
end
