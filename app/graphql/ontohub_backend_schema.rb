# frozen_string_literal: true

OntohubBackendSchema = GraphQL::Schema.define do
  query(Types::QueryType)
end
