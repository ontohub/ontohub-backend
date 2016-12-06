# frozen_string_literal: true

module V2
  # The serializer for the SearchResult, API version 2
  class SearchResultSerializer < ApplicationSerializer
    attributes :id, :results_count,
      :repositories_count, :users_count, :organizations_count

    delegate :id, :results_count,
      :repositories_count, :users_count, :organizations_count, to: :object

    has_many(:repositories, serializer: V2::RepositorySerializer::Relationship)
    has_many(:users, serializer: V2::UserSerializer::Relationship)
    has_many(:organizations,
             serializer: V2::OrganizationSerializer::Relationship)
  end
end
