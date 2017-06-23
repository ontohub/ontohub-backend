# frozen_string_literal: true

module V2
  module Users
    # Session controller generates token
    class SessionsController < Devise::SessionsController
      # Check the credentials and respond with the token
      def create
        super
        render status: :created,
               json: generate_token,
               serializer: AuthenticationTokenSerializer
      end

      protected

      def generate_token
        payload = {user_id: current_user.to_param}
        AuthenticationToken.new(token: JWTWrapper.encode(payload))
      end

      # Disable the flash
      # rubocop:disable Style/AccessorMethodName
      def set_flash_message!(*args); end
      # rubocop:enable Style/AccessorMethodName

      # Disable redirecting
      def respond_with(*args); end
    end
  end
end
