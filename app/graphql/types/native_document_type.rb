# frozen_string_literal: true

Types::NativeDocumentType = GraphQL::ObjectType.define do
  name 'NativeDocument'
  description 'A NativeDocument is a container for exactly one OMS'
  interfaces [Types::DocumentType]
end
