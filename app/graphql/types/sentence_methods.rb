# frozen_string_literal: true

# Methods that should be in Types::SentenceType, but cannot be there
# because of https://github.com/rmosolgo/graphql-ruby/issues/1067
# rubocop:disable Style/ClassAndModuleChildren
module Types::SentenceMethods
  # rubocop:enable Style/ClassAndModuleChildren
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.get(scope)
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
    # Instead of
    # implements Types::LocIdBaseType, inherit: true
    # we need to use
    Types::LocIdBaseMethods.get(scope)
    # because of https://github.com/rmosolgo/graphql-ruby/issues/1067

    scope.field :oms, !Types::OMSType do
      description 'The OMS to which this Sentence belongs'
    end

    scope.field :fileRange, Types::FileRangeType do
      description "The FileRange of this Sentence's definition"
      property :file_range
    end

    scope.field :name, !scope.types.String do
      description 'The name of the Sentence'
    end

    scope.field :text, !scope.types.String do
      description 'The definitional text of this Sentence'
    end

    scope.field :symbols, !scope.types[!Types::SymbolType] do
      description 'The symbols used in this sentence'

      argument :limit, types.Int do
        description 'Maximum number of entries to list'
        default_value 20
      end

      argument :skip, types.Int do
        description 'Skip the first n entries'
        default_value 0
      end

      resolve(lambda do |sentence, arguments, _context|
        sentence.symbols_dataset.
          order(Sequel[:loc_id_bases][:loc_id]).
          limit(arguments['limit'], arguments['skip'])
      end)
    end
  end
end
