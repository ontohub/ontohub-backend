# frozen_string_literal: true

Types::SearchResult::GlobalScopeType = GraphQL::ObjectType.define do
  name 'GlobalSearchScope'
  description 'Search results within the global scope'

  field :entries, !types[!Types::SearchResult::GlobalScope::EntryType] do
    description 'A list of result entries'
  end

  field :count, !Types::SearchResult::GlobalScope::CountType do
    description 'The total numbers of found entries'
  end
end
