# frozen_string_literal: true

# Helper methods for git handling
module GitHelper
  extend module_function

  def git_user(user, time = nil)
    {name: user.name.present? ? user.name : user.to_param,
     email: user.email,
     time: time || Time.now}
  end

  def exclusively(repository)
    FileLockHelper.exclusively(repository.to_param, timeout: 1.minute) { yield }
  end
end
