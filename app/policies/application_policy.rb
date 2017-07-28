# frozen_string_literal: true

# Default Policies
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record

    return unless @user&.admin?
    (self.class.instance_methods - Object.methods).each do |method|
      define_singleton_method(method, ->(*_args) { true })
    end
  end
end
