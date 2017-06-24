# frozen_string_literal: true

OntohubBackendSchema = GraphQL::Schema.define do
  resolve_type ->(obj, _ctx) { "Types::#{obj.kind}Type".constantize }
  query(Types::QueryType)
  mutation(Types::MutationType)

  orphan_types [Types::UserType, Types::OrganizationType]
end
