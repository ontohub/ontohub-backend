# frozen_string_literal: true

Types::Git::TagType = GraphQL::ObjectType.define do
  name 'Tag'
  description 'A git tag'

  implements Types::Git::ReferenceType, inherit: true

  field :annotation, types.String do
    description 'An annotation of the tag'
    property :message
  end
end
