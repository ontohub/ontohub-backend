# frozen_string_literal: true

# Default Policies
class ApplicationPolicy
  attr_reader :current_user, :resource

  def initialize(current_user = nil, resource = nil)
    @current_user = current_user
    @resource = resource

    return unless @current_user&.admin?
    (self.class.instance_methods - Object.methods).each do |method|
      define_singleton_method(method, ->(*_args) { true })
    end
  end
end
