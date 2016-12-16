# frozen_string_literal: true

module V2
  # The serializer for the SearchResult, API version 2
  class VersionSerializer < ApplicationSerializer
    attributes :full, :commit, :tag, :commits_since_tag
    delegate :full, :commit, :tag, :commits_since_tag, to: :object
  end
end
