# frozen_string_literal: true

# Default Policies
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record

    if @user&.admin?
      (self.class.instance_methods - Object.methods).each do |method|
        define_singleton_method(method, ->(*args) { true })
      end
    end
  end
end
