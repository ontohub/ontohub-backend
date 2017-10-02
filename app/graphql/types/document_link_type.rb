# frozen_string_literal: true

Types::DocumentLinkType = GraphQL::ObjectType.define do
  name 'DocumentLink'
  description 'A DocumentLink shows a dependency between Documents'

  field :source, !Types::DocumentType do
    description 'The source Document'
  end

  field :target, !Types::DocumentType do
    description 'The target Document'
  end
end
