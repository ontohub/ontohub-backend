# frozen_string_literal: true

module V2
  module Users
    # Session controller generates token
    class SessionsController < Devise::SessionsController
      # Check the credentials and respond with the token
      def create
        super
        render status: :created,
               json: JWTWrapper.generate_token(current_user),
               serializer: AuthenticationTokenSerializer
      end

      protected

      # Disable the flash
      # rubocop:disable Style/AccessorMethodName
      def set_flash_message!(*args); end
      # rubocop:enable Style/AccessorMethodName

      # Disable redirecting
      def respond_with(*args); end
    end
  end
end
