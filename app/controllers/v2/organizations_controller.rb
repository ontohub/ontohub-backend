# frozen_string_literal: true

module V2
  # Handles user show requests
  class OrganizationsController < ResourcesController
    find_param :slug
    actions :show
    permitted_includes 'repositories'
  end
end
