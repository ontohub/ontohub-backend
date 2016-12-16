# frozen_string_literal: true

module V2
  # This controller is the base class for controllers that need to re-route a
  # request to the action of another controller.
  class ReroutingController < ApplicationController
    protected

    def send_controller_action(action, resource)
      @resource = resource
      @other_controller = controller_class(resource).new
      define_state
      remap_params(action)
      @other_controller.send(action)
      self.response_body = @other_controller.response_body
    end

    private

    def controller_class(resource)
      "V2::#{resource.class.to_s.pluralize}Controller".constantize
    end

    def define_state
      @other_controller.instance_variable_set(:@resource,
                                              instance_variable_get(:@resource))
      @other_controller.request = request
      @other_controller.response = response
    end

    def remap_params(action)
      params['controller'] = @other_controller.controller_path
      params['action'] = action.to_s
      rename_model_based_params_key
      @other_controller.instance_variable_set(:@_params, params)
    end

    def model_based_params_key(controller)
      controller.class.to_s.sub(/\AV2::/, '').sub(/Controller\z/, '').
        underscore.singularize
    end

    def rename_model_based_params_key
      current_key = model_based_params_key(self)
      target_key = model_based_params_key(@other_controller)
      params[target_key] = params.delete(current_key).to_h
    end
  end
end
