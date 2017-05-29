# frozen_string_literal: true

module V2
  # Handles all requests for file CRUD operations. Although this inherits from
  # ResourcesController, we only use a few methods from it and overwrite most of
  # it.
  class TreesController < ResourcesController
    resource_class Blob
    permitted_params %i(path content encoding commit_message previous_head_sha)

    def show
      if resource
        render_resource
      elsif resource_tree
        render status: :ok,
               json: resource_tree,
               serializer: V2::TreeSerializer,
               include: []
      else # nil
        render status: :not_found
      end
    end

    def create
      build_resource
      resource.create
      render_resource(:created)
    rescue Blob::ValidationFailed
      render_error(:unprocessable_entity)
    end

    def update
      if resource
        begin
          update_resource
          render_resource
        rescue Blob::ValidationFailed
          render_error(:unprocessable_entity)
        end
      else
        render status: :not_found
      end
    end

    def destroy
      super
    rescue Blob::ValidationFailed
      render_error(:unprocessable_entity)
    end

    def multiaction
      @resource = MultiBlob.new(files: params[:data][:attributes][:files],
                                commit_message:
                                  resource_params[:commit_message],
                                branch: ref,
                                repository: repository,
                                user: current_user)
      render_resource(:ok, serializer: V2::MultiBlobSerializer) if resource.save
    rescue MultiBlob::ValidationFailed
      render_error(:unprocessable_entity)
    end

    protected

    def repository
      RepositoryCompound.find(slug: params[:repository_slug])
    end

    def git
      repository.git
    end

    def ref
      params[:ref] || git.default_branch
    end

    def resource_tree
      @resource_tree ||= Tree.find(repository_id: repository.to_param,
                                   branch: ref,
                                   path: params[:path])
    end

    def resource
      return @resource if @resource
      @resource = Blob.find(repository_id: repository.to_param,
                            branch: ref,
                            path: params[:path])
      @resource&.user = current_user
      @resource
    end

    def build_resource
      @resource =
        Blob.new(resource_params.merge(branch: ref,
                                       repository: repository,
                                       user: current_user))
    end

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def update_resource
      attributes = {commit_message: resource_params[:commit_message],
                    branch: ref,
                    repository: repository,
                    user: current_user}
      # Only for moving the file
      if resource_params[:path]
        attributes[:path] = resource_params[:path]
        attributes[:previous_path] = params[:path]
      else
        attributes[:path] = params[:path]
        attributes[:previous_path] = nil
      end
      # Only if changing the content
      attributes[:content] = resource_params[:content]
      attributes[:encoding] = resource_params[:encoding]

      resource.update(attributes)
      resource.save
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
