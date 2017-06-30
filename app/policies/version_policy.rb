class VersionPolicy < ApplicationPolicy

  def initialize(_current_user = nil, _resource = nil)
    super
  end

  def show?
    true
  end
end
