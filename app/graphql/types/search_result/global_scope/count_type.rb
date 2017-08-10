# frozen_string_literal: true

Types::SearchResult::GlobalScope::CountType = GraphQL::ObjectType.define do
  name 'GlobalSearchCount'
  description 'The total numbers of results'

  field :all, !types.Int do
    description 'The total number of search results'
  end

  field :organizationalUnits, !types.Int do
    property :organizational_units
    description 'The total number of found organizational units'
  end

  field :repositories, !types.Int do
    description 'The total number of found repositories'
  end
end
