# frozen_string_literal: true

Types::SignatureMorphismType = GraphQL::ObjectType.define do
  name 'SignatureMorphism'
  description 'A morphism between two Signatures'

  field :id, !types.Int do
    description 'The ID of the SignatureMorphism'
  end

  field :logicMapping, !Types::LogicMappingType do
    description 'The LogicMapping which this SignatureMorphism uses'
    property :logic_mapping
  end

  field :asJson, !types.String do
    description "The SignatureMorphism's mappings in JSON"
    property :as_json
  end

  field :source, !Types::SignatureType do
    description 'The source Signature'
  end

  field :target, !Types::SignatureType do
    description 'The target Signature'
  end

  field :mappings, !types[!Types::MappingType] do
    description 'The Mappings that use this SignatureMorphism'
  end

  field :symbolMappings, !types[!Types::SymbolMappingType] do
    description 'The SymbolMappings of this SignatureMorphism'
    property :symbol_mappings
  end
end
