# frozen_string_literal: true

Types::SymbolMappingType = GraphQL::ObjectType.define do
  name 'SymbolMapping'
  description 'A mapping between two symbols along a SignatureMorphism'

  field :signatureMorphism, !Types::SignatureMorphismType do
    description 'The SignatureMorphism to which this SymbolMapping belongs'
    property :signature_morphism
  end

  field :source, !Types::SymbolType do
    description 'The source symbol'
  end

  field :target, !Types::SymbolType do
    description 'The target symbol'
  end
end
