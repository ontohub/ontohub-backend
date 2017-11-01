# frozen_string_literal: true

Types::SineSymbolPremiseTriggerType = GraphQL::ObjectType.define do
  name 'SineSymbolPremiseTrigger'
  description <<~DESCRIPTION
    Shows the tolerance needed for a Symbol to trigger (select) a premise
  DESCRIPTION

  field :sinePremiseSelection, !Types::SinePremiseSelectionType do
    description 'The SinePremiseSelection'
    property :sine_premise_selection
  end

  field :premise, !Types::SentenceType do
    description 'The premise'
  end

  field :symbol, !Types::SymbolType do
    description 'The Symbol'
  end

  field :minTolerance, !types.Float do
    description <<~DESCRIPTION
      The tolerance needed for a Symbol to trigger (select) a premise
    DESCRIPTION
    property :min_tolerance
  end
end
