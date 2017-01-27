# frozen_string_literal: true

module V2
  module Users
    # Session controller generates token
    class SessionsController < Devise::SessionsController
      # GET /resource/sign_in
      # def new
      #   super
      # end

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

      # DELETE /resource/sign_out
      # def destroy
      #   super
      # end

      protected

      def generate_token
        payload = {user_id: current_user.id}
        AuthenticationToken.new(token: JWTWrapper.encode(payload))
      end

      # If you have extra params to permit, append them to the sanitizer.
      # def configure_sign_in_params
      #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
      # end
    end
  end
end
