# frozen_string_literal: true

Types::LogicType = GraphQL::ObjectType.define do
  name 'Logic'
  description 'A logic'

  field :id, !types.ID do
    description 'The ID of this logic'
    property :slug
  end

  field :language, !Types::LanguageType do
    description 'The language to which this logic belongs'
  end

  field :name, !types.String do
    description 'The name of this logic'
  end

  field :logicMappings, !types[!Types::LogicMappingType] do
    description 'A LogicMapping of which this Logic is the source or the target'

    argument :origin, Types::LinkOriginEnum do
      description <<~DESCRIPTION
        Specifies which end of the link the current Logic is
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

    resolve(lambda do |logic, arguments, _context|
      case arguments['origin']
      when 'source'
        logic.logic_mappings_by_source_dataset
      when 'target'
        logic.logic_mappings_by_target_dataset
      else
        logic.logic_mappings_dataset
      end.order(Sequel[:logic_mappings][:slug]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
