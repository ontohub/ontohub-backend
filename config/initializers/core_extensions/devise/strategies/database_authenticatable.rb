# frozen_string_literal: true

# rubocop:disable Style/ClassAndModuleChildren
# This is monkey-patching devise's DatabaseAuthenticatable to call fail! when
# providing an invalid username/password combination
class Devise::Strategies::DatabaseAuthenticatable <
    ::Devise::Strategies::Authenticatable
  def fail(message = 'Failed to Login')
    fail!(message)
  end
end
