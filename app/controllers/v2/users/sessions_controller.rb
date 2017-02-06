# frozen_string_literal: true

module V2
  module Users
    # Session controller generates token
    class SessionsController < Devise::SessionsController
      # POST /resource/sign_in
      def create
        self.resource = warden.authenticate!(auth_options)
        sign_in(resource_name, resource)
        yield resource if block_given?
        return false unless user_signed_in?
        render status: :created,
               json: generate_token,
               serializer: AuthenticationTokenSerializer
      end

      protected

      def generate_token
        payload = {user_id: current_user.to_param}
        AuthenticationToken.new(token: JWTWrapper.encode(payload))
      end
    end
  end
end
