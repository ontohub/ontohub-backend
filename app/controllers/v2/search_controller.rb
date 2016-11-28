# frozen_string_literal: true

module V2
  # The SearchController presents the search result
  class SearchController < ApplicationController
    def search
      render status: :ok,
             json: resource,
             serializer: V2::SearchResultSerializer
    end

    protected

    def resource
      @resource ||= SearchResult.new(params)
    end
  end
end
