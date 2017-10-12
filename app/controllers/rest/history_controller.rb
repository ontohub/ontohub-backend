# frozen_string_literal: true

module Rest
  # Handles requests for history read operations
  class HistoryController < Rest::ApplicationController
    graphql :index do
      arguments do
        organizational_unit_id = params[:organizational_unit_id]
        repository_id = params[:repository_id]
        {'id' => "#{organizational_unit_id}/#{repository_id}",
         'revision' => params[:revision],
         'path' => params[:path]}
      end
      query <<-QUERY
        query ($id: ID!, $revision: String) {
          repository(id: $id) {
            log (revision: $revision) {
              id
              message
              committedAt
            }
          }
        }
      QUERY
    end
  end
end
