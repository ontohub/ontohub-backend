# frozen_string_literal: true

module Rest
  # Handles requests for version show operations
  class VersionController < Rest::ApplicationController
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
