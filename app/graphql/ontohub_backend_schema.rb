# frozen_string_literal: true

OntohubBackendSchema = GraphQL::Schema.define do
  resolve_type(lambda do |_type, root, _context|
    if root.respond_to?(:kind)
      "Types::#{root.kind}Type".constantize
    else
      # If we return objects of class xyzCompound, remove the Compound suffix to
      # find the correct GraphQL type
      "Types::#{root.class.to_s.sub(/Compound\z/, '')}Type".constantize
    end
  end)
  # The last Instrumenter is executed first, so make sure these are in the
  # correct order
  instrument(:field, Instrumenters::ValidationErrorInstrumenter.new)
  instrument(:field, Instrumenters::ResourceInstrumenter.new)
  query(Types::QueryType)
  mutation(Types::MutationType)
  orphan_types [Types::Git::DirectoryType]
end
