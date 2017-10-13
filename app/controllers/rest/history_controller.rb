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
         'path' => params[:path],
         'limit' => params[:limit] && params[:limit].to_i,
         'skip' => params[:skip] && params[:skip].to_i,
         'skipMerges' => ![nil, '', '0', 'false'].
           include?(params[:skipMerges]),
         'before' => params[:before] && params[:before].to_i,
         'after' => params[:after] && params[:after].to_i}
      end
      query <<-QUERY
        query ($id: ID!, $revision: String, $limit: Int, $skip: Int, $skipMerges: Boolean, $before: Time, $after: Time) {
          repository(id: $id) {
            log (revision: $revision, limit: $limit, skip: $skip, skipMerges: $skipMerges, before: $before, after: $after) {
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
