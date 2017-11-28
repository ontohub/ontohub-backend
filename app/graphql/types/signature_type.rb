# frozen_string_literal: true

Types::SignatureType = GraphQL::ObjectType.define do
  name 'Signature'
  description "A signautre of an OMS is a container for the OMS's symbols"

  field :id, !types.Int do
    description 'The ID of this signature'
  end

  field :asJson, !types.String do
    description "The signature's symbols in JSON"
    property :as_json
  end

  field :oms, !types[!Types::OMSType] do
    description 'OMS that have this signature'
  end

  field :symbols, !types[!Types::SymbolType] do
    description 'The Symbols of this Signature'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    argument :origin, Types::SymbolOriginEnum do
      description <<~DESCRIPTION
        Whether or not only (non-)imported Symbols should be retrieved
      DESCRIPTION
      default_value 'either'
    end

    resolve(lambda do |signature, arguments, _context|
      case arguments['origin']
      when 'imported'
        signature.imported_symbols_dataset
      when 'non_imported'
        signature.non_imported_symbols_dataset
      else
        signature.symbols_dataset
      end.order(Sequel[:loc_id_bases][:loc_id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :signatureMorphisms, !types[!Types::SignatureMorphismType] do
    description <<~DESCRIPTION
      The SignatureMorphisms of which this Signature is the target
    DESCRIPTION

    argument :origin, Types::LinkOriginEnum do
      description <<~DESCRIPTION
        Specifies which end of the link the current Signature is
      DESCRIPTION
      default_value 'any'
    end

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |signature, arguments, _context|
      case arguments['origin']
      when 'source'
        signature.signature_morphisms_by_source_dataset
      when 'target'
        signature.signature_morphisms_by_target_dataset
      else
        signature.signature_morphisms_dataset
      end.order(Sequel[:signature_morphisms][:id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
