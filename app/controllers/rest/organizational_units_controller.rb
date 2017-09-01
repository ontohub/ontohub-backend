# frozen_string_literal: true

module Rest
  # Handles requests for organizational unit show operations
  class OrganizationalUnitsController < Rest::ApplicationController
    graphql :show do
      arguments do
        {'id' => params[:slug]}
      end

      query <<-QUERY
        query OrganizationalUnit($id: ID!) {
          organizationalUnit(id: $id) {
            __typename
            id
            displayName
            ... on User {
              emailHash
              organizations {
                id
              }
            }
            ... on Organization {
              description
              members {
                id
              }
            }
          }
        }
      QUERY
    end
  end
end
