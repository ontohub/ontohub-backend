# frozen_string_literal: true

module V2
  # Handles all requests for repository CRUD operations
  class RepositoriesController < ResourcesController
    find_param :slug
    actions :all
    permitted_params :description, create: [:name, :description, :namespace_id]

    def create
      # On objects that are identified by the slug, we must translate the given
      # parameter to the id.
      namespace = Namespace.find(slug: resource_params[:namespace_id])
      resource_params[:namespace_id] = namespace&.id
      super
    end
  end
end
