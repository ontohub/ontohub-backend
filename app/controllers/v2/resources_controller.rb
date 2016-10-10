# frozen_string_literal: true

module V2
  # This is the base class for all resourceful API Version 2 controllers. It
  # defines default actions such that simple CRUD controllers don't need to
  # define them over and over again.
  # It is configurable with the methods:
  #   SheetsController < ResourcesController
  #     resource_class Paper # is inferred automatically
  #     find_param :slug # defaults to :id
  #     actions :all, except: :index # defaults to :all
  #     # or
  #     actions :index, :show
  #     # or
  #     actions %i(index show)
  #   end
  #
  # It also defines the chaching getters +resource+ and +collection+ for easy
  # access to the requested data.
  class ResourcesController < ApplicationController
    # Simplify calling of resource and collection
    include ResourcesHelpers::InstanceMethods
    extend ResourcesHelpers::ClassMethods

    def self.inherited(subclass)
      subclass.infer_resource_class
      subclass.find_param(:id)
      subclass.permitted_params([])
      subclass.permitted_includes([])
      super(subclass)
    end

    def index
      render status: :ok,
             json: collection,
             each_serializer: resource_serializer
    end

    def show
      if resource
        render_resource
      else
        render status: :not_found
      end
    end

    def create
      permitted_params
      @resource = resource_class.new(resource_params)
      resource.save
      render_resource(:created)
    rescue Sequel::ValidationFailed
      render_error(:unprocessable_entity)
    end

    def update
      if resource
        begin
          resource.update(resource_params)
          render_resource
        rescue Sequel::ValidationFailed
          render_error(:unprocessable_entity)
        end
      else
        render status: :not_found
      end
    end

    def destroy
      if resource
        resource.destroy
        render status: :no_content
      else
        render status: :not_found
      end
    end

    protected

    def render_resource(status = :ok)
      render status: status,
             json: resource,
             serializer: resource_serializer
    end

    def render_error(status)
      render status: status,
             json: resource,
             serializer: ActiveModel::Serializer::ErrorSerializer
    end

    def resource_params
      @resource_params ||= parse_params(only: permitted_params)
    end

    def permitted_includes
      permitted = self.class.instance_variable_get(:@permitted_includes)
      requested = params[:include]&.split(',') || []
      @permitted_includes ||= requested & permitted
    end

    private

    def resource_class
      self.class.instance_variable_get(:@resource_class)
    end

    def resource_serializer
      "V2::#{resource_class}Serializer".constantize
    end

    def parse_params(**options)
      ActiveModelSerializers::Deserialization.jsonapi_parse!(params, **options)
    end

    def permitted_params(action = params[:action].to_sym)
      permitted = self.class.instance_variable_get(:@permitted_params)
      if permitted.last.is_a?(Hash)
        permitted.last[action] || permitted[0..2]
      else
        permitted
      end
    end
  end
end
