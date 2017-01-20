# frozen_string_literal: true

module V2
  # The serializer for the AuthenticationToken, API version 2
  class AuthenticationTokenSerializer < ApplicationSerializer
    attributes :id, :token
  end
end
