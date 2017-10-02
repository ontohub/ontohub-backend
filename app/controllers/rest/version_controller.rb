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

      plain do |graphql_executor, _variables, _context|
        graphql_executor.call.dig('data', 'version', 'full')
      end
    end
  end
end
