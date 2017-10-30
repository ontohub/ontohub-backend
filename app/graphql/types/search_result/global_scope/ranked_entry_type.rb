# frozen_string_literal: true

Types::SearchResult::GlobalScope::RankedEntryType =
  GraphQL::ObjectType.define do
    name 'RankedGlobalSearchEntry'
    description 'A search result entry'

    field :ranking, !types.Float do
      description <<~DESCRIPTION
        The ranking of the result entry. The higher the value, the better it
        matches the search query
      DESCRIPTION
    end

    field :entry, !Types::SearchResult::GlobalScope::EntryType do
      description 'The actual result entry'
    end
  end
