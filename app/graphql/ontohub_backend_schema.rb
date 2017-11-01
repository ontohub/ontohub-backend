# frozen_string_literal: true

OntohubBackendSchema = GraphQL::Schema.define do
  resolve_type(lambda do |_type, root, _context|
    if root.respond_to?(:kind)
      "Types::#{root.kind}Type".constantize
    else
      "Types::#{root.model_name}Type".constantize
    end
  end)

  # The last Instrumenter is executed first, so make sure these are in the
  # correct order
  instrument(:field, Instrumenters::ValidationErrorInstrumenter.new)
  instrument(:field, GraphQL::Pundit::Instrumenter.new)
  instrument(:field, Instrumenters::NotFoundUnlessInstrumenter.new)
  instrument(:field, Instrumenters::ResourceInstrumenter.new)
  query(Types::QueryType)
  mutation(Types::MutationType)
  orphan_types [
    Types::Git::DirectoryType,
    Types::NativeDocumentType,
    Types::LibraryType,
    Types::AxiomType,
    Types::OpenConjectureType,
    Types::TheoremType,
    Types::CounterTheoremType,
    Types::ErrorType,
    Types::WarnType,
    Types::HintType,
    Types::DebugType,
    Types::ManualPremiseSelectionType,
    Types::SinePremiseSelectionType,
  ]
end
