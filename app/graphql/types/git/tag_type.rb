# frozen_string_literal: true

Types::Git::TagType = GraphQL::ObjectType.define do
  name 'Tag'
  description 'A git tag'
  interfaces [Types::Git::ReferenceType]

  field :annotation, types.String do
    description 'An annotation of the tag'
    property :message
  end
end
