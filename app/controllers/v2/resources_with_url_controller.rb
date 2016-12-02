# frozen_string_literal: true

module V2
  # This class adds capabilities to the controller that allow setting a URL for
  # the resource.
  class ResourcesWithURLController < ResourcesController
    def self.inherited(subclass)
      super(subclass)
      subclass.instance_eval do
        action =
          begin
            ROUTE_PREFIX_ACTION
          rescue NameError
            'show'
          end
        @route_prefix = route_prefix(action || 'show')
      end
    end

    # rubocop:disable Metrics/AbcSize
    def self.route_prefix(action)
      routes =
        Rails.application.routes.routes.select do |r|
          r.defaults[:controller] == controller_path &&
            r.defaults[:action] == action
        end
      routes.first.
        instance_variable_get(:@path_formatter).
        instance_variable_get(:@parts).
        select { |p| p.is_a?(String) }.join
    end

    def self.resource_url_path(resource)
      [@route_prefix, resource.to_param].join
    end

    protected

    def build_resource
      super
      resource.url_path_method = lambda do |r|
        self.class.resource_url_path(r)
      end
    end
  end
end
