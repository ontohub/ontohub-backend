# frozen_string_literal: true

module Rest
  # Handles requests for tag read operations
  class TagsController < Rest::ApplicationController
    graphql :index do
      arguments do
        organizational_unit_id = params[:organizational_unit_id]
        repository_id = params[:repository_id]
        {'id' => "#{organizational_unit_id}/#{repository_id}"}
      end
      query <<-QUERY
        query ($id: ID!) {
          repository(id: $id) {
            tags
          }
        }
      QUERY
    end
    graphql :show do
      arguments do
        organizational_unit_id = params[:organizational_unit_id]
        repository_id = params[:repository_id]
        {'id' => "#{organizational_unit_id}/#{repository_id}",
         'name' => params[:name]}
      end
      query <<-QUERY
        query ($id: ID!, $name: String!) {
          repository(id: $id) {
            tag(name: $name) {
              name
              target {
                id
              }
              annotation
            }
          }
        }
      QUERY
    end
  end
end
