# frozen_string_literal: true

module V2
  # The serializer for the SearchResult, API version 2
  class SearchResultSerializer < ApplicationSerializer
    attributes :id, :results_count,
      :repositories_count, :organizational_units_count

    delegate :id, :results_count,
      :repositories_count, :organizational_units_count, to: :object

    has_many(:repositories,
             serializer: V2::RepositoryCompoundSerializer::Relationship)
    has_many(:organizational_units,
             serializer: V2::UserSerializer::Relationship)
  end
end
