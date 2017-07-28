# frozen_string_literal: true

Types::SearchResult::GlobalScope::EntryType = GraphQL::ObjectType.define do
  name 'GlobalSearchEntry'
  description 'A search result entry'

  field :ranking, !types.Float do
    description <<~DESCRIPTION
      The ranking of the result entry. The higher the value, the better it
      matches the search query
    DESCRIPTION
  end

  field :entry, !Types::SearchResult::GlobalScope::TargetType do
    description 'The actual result entry'
  end
end
