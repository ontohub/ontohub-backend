# frozen_string_literal: true

Types::SearchResultType = GraphQL::ObjectType.define do
  name 'SearchResult'
  description <<~DESCRIPTION
    Result returned from a search query
  DESCRIPTION

  field :global, !Types::SearchResult::GlobalScopeType do
    description 'Search within the global scope'

    argument :categories do
      type types[Types::SearchResult::GlobalScope::CategoryEnum]
      description 'Limit search to certain categories'
    end

    resolve(lambda do |_root, arguments, _context|
      SearchResult.new(categories: arguments['categories'])
    end)
  end
end
