# frozen_string_literal: true

module V2
  # Handles all requests for repository CRUD operations
  class RepositoriesController < ApplicationController
    def index
      @collection = Repository.all
      render json: @collection, each_serializer: V2::RepositorySerializer
    end

    def show
      retrieve_resource
      render_resource
    end

    def create
      @resource = Repository.new(resource_params)
      begin
        @resource.save
        render_resource
      rescue Sequel::ValidationFailed
        render_error(422)
      end
    end

    def update
      if retrieve_resource
        begin
          @resource.update(resource_params)
          render_resource
        rescue Sequel::ValidationFailed
          render_error(422)
        end
      else
        render status: 404
      end
    end

    def destroy
      if retrieve_resource
        @resource.destroy
        render status: 204
      else
        render status: 404
      end
    end

    private

    def resource_params
      ActiveModelSerializers::Deserialization.
        jsonapi_parse!(params, only: %i(name description))
    end

    def retrieve_resource
      @resource ||= Repository.find(slug: params[:slug])
    end

    def render_resource
      render json: @resource, serializer: V2::RepositorySerializer
    end

    def render_error(status)
      render status: status,
             json: @resource,
             serializer: ActiveModel::Serializer::ErrorSerializer
    end
  end
end
