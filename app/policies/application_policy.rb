# frozen_string_literal: true

# Default Policies
class ApplicationPolicy
  # Scopes a dataset. Is supposed to be subclassed.
  class Scope
    attr_reader :current_user, :scope

    def initialize(current_user, scope)
      @current_user = current_user
      @scope = scope
    end

    def resolve
      # overwrite this method in the subclass
    end

    protected

    def admin?
      user? && current_user.admin?
    end

    def user?
      current_user.is_a?(User)
    end

    def git_shell_api_key?
      current_user.is_a?(GitShellApiKey)
    end

    def hets_api_key?
      current_user.is_a?(HetsApiKey)
    end
  end

  attr_reader :current_user, :resource

  def initialize(current_user = nil, resource = nil)
    @current_user = current_user
    @resource = resource

    define_methods(true) if admin?
  end

  protected

  def admin?
    user? && current_user.admin?
  end

  def user?
    current_user.is_a?(User)
  end

  def signed_in?
    !!current_user
  end

  def not_an_api_key?
    !signed_in? || user?
  end

  def git_shell_api_key?
    current_user.is_a?(GitShellApiKey)
  end

  def hets_api_key?
    current_user.is_a?(HetsApiKey)
  end

  private

  def define_methods(result)
    (self.class.instance_methods - Object.methods).each do |method|
      define_singleton_method(method, ->(*_args) { result })
    end
  end
end
