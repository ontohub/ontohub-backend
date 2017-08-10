# frozen_string_literal: true

Types::SearchResult::GlobalScope::CategoryEnum = GraphQL::EnumType.define do
  name 'GlobalSearchCategory'
  description 'Category to search in'

  value 'repositories', 'Search only for repositories'
  value 'organizationalUnits', 'Search only for organizational units'
end
