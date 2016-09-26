# frozen_string_literal: true

module V2
  # Handles all requests for repository CRUD operations
  class RepositoriesController < ResourcesController
    find_param :slug
    permitted_params :description, create: [:name, :description]
    actions :all
  end
end
