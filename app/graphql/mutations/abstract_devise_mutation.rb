# frozen_string_literal: true

require 'ostruct'

module Mutations
  # Abstract mutation for Devise handling. It is supposed to be inherited from
  # for all Devise actions.
  class AbstractDeviseMutation
    include Devise::Controllers::SignInOut

    # These are needed for Devise's SignInOut module
    attr_reader :request, :session, :warden

    protected

    # :nocov:
    # We don't have a request object in the mutation specs.
    # Also, we don't want to test devise internals.
    def setup_devise(context)
      @request = context[:request]
      env = request.env
      @warden = env['warden']
      @session = warden.request.session
      @params = request.params

      env['devise.allow_params_authentication'] = Devise.params_authenticatable
    end
    # :nocov:

    def sign_in_and_return_token(user)
      # :nocov:
      # We don't have a request object in the mutation specs.
      # Also, we don't want to test devise internals.
      sign_in(:user, user)
      # :nocov:
      authentication_token = JWTWrapper.generate_token(user)
      OpenStruct.new(jwt: authentication_token.token, me: user)
    end
  end
end
