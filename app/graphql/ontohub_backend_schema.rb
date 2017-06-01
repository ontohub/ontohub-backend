# frozen_string_literal: true

OntohubBackendSchema = GraphQL::Schema.define do
  resolve_type ->(obj, _ctx) { "Types::#{obj.kind}".constantize }
  query(Types::QueryType)

  # GraphQL::Batch setup:
  use GraphQL::Batch
end
