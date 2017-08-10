# frozen_string_literal: true

Types::SearchResult::GlobalScope::EntryType = GraphQL::UnionType.define do
  name 'GlobalSearchEntry'
  description 'Possible search result types'

  possible_types [Types::RepositoryType,
                  Types::OrganizationType,
                  Types::UserType]
end
