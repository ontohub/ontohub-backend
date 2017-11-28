# frozen_string_literal: true

Types::SymbolType = GraphQL::ObjectType.define do
  name 'Symbol'
  description 'A (non-logical) symbol'

  implements Types::LocIdBaseType, inherit: true

  field :oms, !Types::OMSType do
    description 'The OMS to which this Symbol belongs to'
  end

  field :fileRange, Types::FileRangeType do
    description "The FileRange of this Symbol's definition"
    property :file_range
  end

  field :sentences, !types[!Types::SentenceType] do
    description 'The Sentences in which this Symbol occurs'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |symbol, arguments, _context|
      symbol.sentences_dataset.
        order(Sequel[:loc_id_bases][:loc_id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :signatures, !types[!Types::SignatureType] do
    description 'The Signatures in which this Symbol occurs'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |symbol, arguments, _context|
      symbol.signatures_dataset.
        order(Sequel[:signatures][:id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :kind, !types.String do
    description 'The kind of the Symbol'
    property :symbol_kind
  end

  field :name, !types.String do
    description 'The name of the Symbol'
  end

  field :fullName, !types.String do
    description 'The fully qualified name of the Symbol'
    property :full_name
  end
end
