# frozen_string_literal: true

module V2
  # Handles all requests for repository CRUD operations
  class NamespacesController < ResourcesController
    find_param :slug
    actions :show
  end
end
