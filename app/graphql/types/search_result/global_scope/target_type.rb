# frozen_string_literal: true

Types::SearchResult::GlobalScope::TargetType = GraphQL::UnionType.define do
  name 'GlobalSearchTarget'
  description 'Possible search result types'

  possible_types [Types::RepositoryType,
                  Types::OrganizationType,
                  Types::UserType]
end
