class UnlockPolicy < ApplicationPolicy

  def initialize(_current_user = nil, _resource = nil)
    super
  end

  def resend_unlocking_email?
    true
  end

  def unlock_account?
    true
  end
end
