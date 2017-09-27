# frozen_string_literal: true

module Rest
  # Handles requests for commit read operations
  class CommitsController < Rest::ApplicationController
    graphql :show do
      arguments do
        organizational_unit_id = params[:organizational_unit_id]
        repository_id = params[:repository_id]
        {'id' => "#{organizational_unit_id}/#{repository_id}",
         'revision' => params[:revision]}
      end
      query <<-QUERY
        query ($id: ID!, $revision: ID) {
          repository(id: $id) {
            commit(revision: $revision) {
              id
              message
              parentIds
              referenceNames
              references {
                name
                target {
                  id
                }
              }
              author {
                account {
                  id
                }
                email
                name
              }
              authoredAt
              committer {
                account {
                  id
                }
                email
                name
              }
              committedAt
            }
          }
        }
      QUERY
    end
  end
end
