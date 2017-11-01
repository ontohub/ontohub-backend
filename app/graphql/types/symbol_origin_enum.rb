# frozen_string_literal: true

Types::SymbolOriginEnum = GraphQL::EnumType.define do
  name 'SymbolOrigin'
  description 'Specifies which end of the link the current Symbol is'

  value 'either', 'The current Symbol is either imported or or not'
  value 'imported', 'The current Symbol is imported'
  value 'non_imported', 'The current Symbol is not imported'
end
