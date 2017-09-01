# frozen_string_literal: true

# model for AuthenticationToken
class AuthenticationToken
  attr_accessor :token

  def initialize(token:)
    @token = token
  end
end
