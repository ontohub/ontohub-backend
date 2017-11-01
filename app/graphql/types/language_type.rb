# frozen_string_literal: true

Types::LanguageType = GraphQL::ObjectType.define do
  name 'Language'
  description 'A logical language'

  field :id, !types.ID do
    description 'The ID of this language'
    property :slug
  end

  field :name, !types.String do
    description 'The name of this language'
  end

  field :description, !types.String do
    description 'The description of this language'
  end

  field :standardizationStatus, !types.String do
    description 'The standardization status of this language'
    property :standardization_status
  end

  field :definedBy, !types.String do
    description 'Where this language has been defined'
    property :defined_by
  end

  field :languageMappings, !types[!Types::LanguageMappingType] do
    description <<~DESCRIPTION
      A LanguageMapping of which this Language is the source or the target
    DESCRIPTION

    argument :origin, Types::LinkOriginEnum do
      description <<~DESCRIPTION
        Specifies which end of the link the current Language is
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

    resolve(lambda do |language, arguments, _context|
      case arguments['origin']
      when 'source'
        language.language_mappings_by_source_dataset
      when 'target'
        language.language_mappings_by_target_dataset
      else
        language.language_mappings_dataset
      end.order(Sequel[:language_mappings][:id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :logics, !types[!Types::LogicType] do
    description 'The logics of this Language'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |language, arguments, _context|
      language.logics_dataset.
        order(Sequel[:logics][:slug]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
