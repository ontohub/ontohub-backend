# frozen_string_literal: true

module V2
  # Handles all requests for repository CRUD operations
  class RepositoriesController < ResourcesController
    PERMITTED_PARAMS = %i(description content_type public_access).freeze
    resource_class RepositoryCompound
    find_param :slug
    actions :all
    permitted_params PERMITTED_PARAMS,
      create: [:name, :owner, *PERMITTED_PARAMS]

    def collection
      super.select do |repository|
        RepositoryPolicy.new(current_user, repository).show?
      end
    end

    protected

    def authorize_resource
      if %w(create).include?(action_name)
        owner = OrganizationalUnit.find(slug: parse_params[:owner_id])
        unless RepositoryPolicy.new(current_user, Repository).create?(owner)
          raise Pundit::NotAuthorizedError, policy: RepositoryPolicy
        end
      else
        super
      end
    rescue Pundit::NotAuthorizedError
      render status: :unauthorized
    end

    def build_resource
      # On objects that are identified by the slug, we must translate the given
      # parameter to the id.
      owner = OrganizationalUnit.find(slug: resource_params[:owner_id])
      resource_params[:owner_id] = owner&.id
      super
    end

    def parent_params
      return @parent_params unless @parent_params.nil?

      # parse params - owner_slug for index route, slug for other routes
      parts = (params[:slug] || params[:user_slug] ||
               params[:organization_slug]).split('/', 2)
      owner_id = OrganizationalUnit.find(slug: parts.first)&.id
      @parent_params = super.merge(owner_id: owner_id)

      # update params
      @parent_params.each { |key, value| params[key] = value }

      @parent_params
    end
  end
end
