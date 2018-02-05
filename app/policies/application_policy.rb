# frozen_string_literal: true

# Default Policies
class ApplicationPolicy
  attr_reader :current_user, :resource

  def initialize(current_user = nil, resource = nil)
    @current_user = current_user
    @resource = resource

    if current_user.is_a?(HetsApiKey)
      define_methods(false, show?: true)
    elsif current_user.is_a?(GitShellApiKey)
      define_methods(false)
    elsif current_user&.admin?
      define_methods(true)
    end
  end

  private

  def define_methods(default_result, **exceptions)
    (self.class.instance_methods - Object.methods).each do |method|
      result = exceptions[method] || default_result
      define_singleton_method(method, ->(*_args) { result })
    end
  end
end
