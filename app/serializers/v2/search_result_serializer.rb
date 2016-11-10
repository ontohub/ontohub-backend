# frozen_string_literal: true

module V2
  # The serializer for the SearchResult, API version 2
  class SearchResultSerializer < ApplicationSerializer
    attributes :id, :results_count, :repositories_count, :users_count
    delegate :id, :results_count, :repositories_count, :users_count, to: :object

    has_many(:repositories)
    has_many(:users)
  end
end
