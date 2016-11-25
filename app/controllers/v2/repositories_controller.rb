# frozen_string_literal: true

module V2
  # Handles all requests for repository CRUD operations
  class RepositoriesController < ResourcesController
    find_param :slug
    actions :all
    permitted_params :description, :content_type, :public_access,
      create: [:name, :namespace, :description, :content_type,
               :public_access]

    def create
      # On objects that are identified by the slug, we must translate the given
      # parameter to the id.
      namespace = Namespace.find(slug: resource_params[:namespace_id])
      resource_params[:namespace_id] = namespace&.id
      super
    end

    protected

    def parent_params
      return @parent_params unless @parent_params.nil?

      # parse params - namespace_slug for index route, slug for other routes
      parts = (params[:slug] || params[:namespace_slug]).split('/', 2)
      namespace_id = Namespace.find(slug: parts.first)&.id
      @parent_params = super.merge(namespace_id: namespace_id)

      # update params
      @parent_params.each { |key, value| params[key] = value }

      @parent_params
    end
  end
end
