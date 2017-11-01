# frozen_string_literal: true

Types::SineSymbolCommonnessType = GraphQL::ObjectType.define do
  name 'SineSymbolCommonness'
  description 'Shows in how many Sentences of the OMS a Symbol occurs'

  field :sinePremiseSelection, !Types::SinePremiseSelectionType do
    description 'The SinePremiseSelection'
    property :sine_premise_selection
  end

  field :symbol, !Types::SymbolType do
    description 'The Symbol'
  end

  field :commonness, !types.Int do
    description <<~DESCRIPTION
      The commonness of the symbol (number of sentences in which it occurs)
    DESCRIPTION
  end
end
