# frozen_string_literal: true

module V3
  # Handles requests for version show operations
  class VersionController < ApplicationController
    graphql :show do
      query <<-QUERY
        query Version {
          version {
            commit
            commitsSinceTag
            full
            tag
          }
        }
      QUERY
    end
  end
end
