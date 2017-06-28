# frozen_string_literal: true

OntohubBackendSchema = GraphQL::Schema.define do
  resolve_type ->(root, _context) { "Types::#{root.kind}Type".constantize }
  # The last Instrumenter is executed first, so make sure these are in the
  # correct order
  instrument(:field, Instrumenters::ValidationErrorInstrumenter.new)
  instrument(:field, Instrumenters::ResourceInstrumenter.new)
  query(Types::QueryType)
  mutation(Types::MutationType)
end
