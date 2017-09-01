# frozen_string_literal: true

module Rest
  # Handles requests for version show operations
  class RepositoriesController < Rest::ApplicationController
    graphql :index do
      arguments do
        {'limit' => params[:limit]&.to_i,
         'skip' => params[:skip]&.to_i,
         'id' => params[:organizational_unit_id]}
      end
      query <<-QUERY
        query ($limit: Int, $skip: Int, $id: ID!) {
          organizationalUnit(id: $id) {
            id
            repositories(limit: $limit, skip: $skip) {
              id
              name
              defaultBranch
              branches
              contentType
              description
              visibility
              owner {
                id
              }
            }
          }
        }
      QUERY
    end
    graphql :show do
      arguments do
        organizational_unit_id = params[:organizational_unit_id]
        repository_id = params[:repository_id]
        {'id' => "#{organizational_unit_id}/#{repository_id}"}
      end
      query <<-QUERY
        query ($id: ID!) {
          repository(id: $id) {
            id
            name
            defaultBranch
            branches
            contentType
            description
            visibility
            owner {
              id
            }
          }
        }
      QUERY
    end
  end
end
