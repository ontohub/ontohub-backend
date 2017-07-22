# frozen_string_literal: true

Types::Repository::NewType = GraphQL::InputObjectType.define do
  name 'NewRepository'
  description 'Data of a new repository'

  argument :name, !types.ID do
    description 'Name of the repository'
  end
  argument :description, types.String do
    description 'The description of the repository'
  end
  argument :owner, !types.String do
    description 'The ID of the owner'
  end
  argument :contentType, !Types::Repository::ContentTypeEnum, as: :content_type do
    description 'The content type of the repository'
  end
  argument :visibility, !Types::Repository::VisibilityEnum do
    description 'The visibility of the repository'
  end
end
