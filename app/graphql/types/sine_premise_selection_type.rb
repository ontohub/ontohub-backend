# frozen_string_literal: true

Types::SinePremiseSelectionType = GraphQL::ObjectType.define do
  name 'SinePremiseSelection'
  description 'The SInE premise selection heuristic'

  implements Types::PremiseSelectionType, inherit: true

  field :depthLimit, !types.Int do
    description <<~DESCRIPTION
      The maximum number of iterations to be done by the SInE heuristic. The higher, the more premises are selected. A null value indicates that this feature is disabled.
    DESCRIPTION
    property :depth_limit
  end

  field :tolerance, !types.Float do
    description <<~DESCRIPTION
      A higher tolerance value causes more premises to be selected. Minimum value: 1.0.
    DESCRIPTION
  end

  field :premiseNumberLimit, types.Int do
    description <<~DESCRIPTION
      The number of premises to be selected at most. A null value indicates that this feature is disabled.
    DESCRIPTION
    property :premise_number_limit
  end

  field :sineSymbolCommonnesses, !types[!Types::SineSymbolCommonnessType] do
    description 'Shows in how many Sentences of the OMS a Symbol occurs'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |premise_selection, arguments, _context|
      premise_selection.sine_symbol_commonnesses_dataset.
        order(Sequel[:sine_symbol_commonnesses][:id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :sineSymbolPremiseTriggers,
    !types[!Types::SineSymbolPremiseTriggerType] do
    description <<~DESCRIPTION
      Shows the tolerance needed for a Symbol to trigger (select) a premise
    DESCRIPTION

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |premise_selection, arguments, _context|
      premise_selection.sine_symbol_premise_triggers_dataset.
        order(Sequel[:sine_symbol_premise_triggers][:id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
