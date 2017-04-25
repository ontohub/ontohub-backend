# frozen_string_literal: true

module V2
  class ResourcesController
    # Defines methods for detecting the resource class
    module DSL
      # Instance methods to use in a controller
      module InstanceMethods
        def collection
          return @collection if @collection
          klass = self.class.instance_variable_get(:@resource_class)
          @collection = klass.where(parent_params)
          if @collection.respond_to?(:all)
            @collection = @collection.all
          else
            @collection
          end
        end

        def resource
          return @resource if @resource
          klass = self.class.instance_variable_get(:@resource_class)
          find_param = self.class.instance_variable_get(:@find_param)
          @resource = klass.find(find_param => params[find_param],
                                 **parent_params)
        end

        protected

        def parent_params
          {}
        end
      end

      # Class methods that add simple handling of resources
      module ClassMethods
        # The inheritable actions of the ResourceController
        ACTIONS = %i(index show create update destroy).freeze

        # Specify the class of the resource (the model). This is only necessary
        # if the naming of the controller does not correspond to the model.
        # Example:
        #   class SheetsController < ResourceController
        #     resource_class Paper
        #   end
        # if the +SheetsContoller+ handles +Paper+ objects.
        def resource_class(klass)
          instance_variable_set(:@resource_class, klass)
        end

        # Specify the model's attribute for the find method. Defaults to +:id+.
        # Example:
        #   find_param :slug
        # will make the controller call
        #   MyModel.find(slug: params[:slug])
        def find_param(param)
          instance_variable_set(:@find_param, param)
        end

        # Specify the permitted parameters. Only these will be included in the
        # create and update actions.
        # Example:
        #   permitted_params :name, :description
        #   permitted_params :description, create: %i(name description)
        #   permitted_params %i(name description)
        def permitted_params(*params, **opts)
          params = params.first if params.first.is_a?(Array)
          opts = permitted_params_options(params, opts)
          params = params.map(&:to_sym)
          params << opts unless opts.empty?
          instance_variable_set(:@permitted_params, params)
        end

        # Specify the permitted includes. Only these will be allowed in the
        # +include+ GET parameter of the JSON API.
        # Example:
        #   permitted_includes 'ontologies.*', 'mappings'
        #   permitted_includes %w(ontologies.* mappings)
        def permitted_includes(*includes)
          includes = includes.first if includes.first.is_a?(Array)
          includes ||= []
          includes.map!(&:to_s)
          instance_variable_set(:@permitted_includes, includes)
        end

        # Specify the actions that should be inherited from the
        # +ResourceController+.
        # Possible arguments:
        #   actions :all, except: :index
        #   actions :index, :show
        #   actions %i(index show)
        def actions(*to_keep)
          to_keep = to_keep.first if to_keep.first.is_a?(Array)
          to_remove = actions_to_remove(to_keep)
          instance_methods.select { |m| to_remove.include?(m.to_sym) }.
            each { |a| undef_method(a) }
        end

        # This will try to infer the model class. Do not call it directly from
        # the controller. It is supposed to be called during loading of the
        # controller only.
        def infer_resource_class
          klass = to_s.split(':').last.sub(/Controller\z/, '').singularize.
            constantize
          resource_class(klass)
        # rubocop:disable HandleExceptions
        rescue NameError
          # Suppress error if the class could not be found.
          # Otherwise loading controllers with non-standard names will fail
          # because this is called before resource_class can be called by the
          # controller.
        end

        private

        def actions_to_remove(to_keep)
          to_remove = []
          to_remove = Array(to_keep.pop[:except]) if to_keep.last.is_a?(Hash)
          to_remove += ACTIONS - to_keep unless to_keep.first == :all
          to_remove.map(&:to_sym).uniq
        end

        def permitted_params_options(params, opts)
          if params.last.is_a?(Hash)
            opts.merge(params.pop.map do |action, action_params|
              [action, Array(action_params).map(&:to_sym)]
            end&.to_h)
          end
          opts
        end
      end
    end
  end
end
