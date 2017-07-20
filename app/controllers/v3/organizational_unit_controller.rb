# frozen_string_literal: true

module V3
  # Handles requests for organizational unit show operations
  class OrganizationalUnitController < ApplicationController
    graphql :show do
      arguments do
        {'id' => params[:organizational_unit]}
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
