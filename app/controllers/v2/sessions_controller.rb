# frozen_string_literal: true

module V2
  class SessionsController < Devise::SessionsController
    before_action :configure_permitted_parameters
    before_action :custom_authenticate_user!

    def create
      binding.pry
      # self.resource = warden.authenticate!(auth_options)
      # binding.pry
      # sign_in(resource_name, resource)
      # yield resource if block_given?
      if user_signed_in?
        token = generate_token
        render status: :created,
               json: token,
               serializer: AuthenticationTokenSerializer
      end
    end

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in) do |user_params|
        user_params.permit(:sign_in, keys: [:username])
      end
    end

    def custom_authenticate_user!
      parse_params
      authenticate_user!
    end

    def parse_params
      params.merge!(user: ActiveModelSerializers::Deserialization.jsonapi_parse!(params, only: %i(name password)))
    end

    def generate_token
      payload = {user_id: current_user.id}
      AuthenticationToken.new(token: JWTWrapper.encode(payload))
    end

    # def decode
    #   begin
    #     decoded_token = JWT.decode(token, ecdsa_public,
    #                      true, {:algorithm => 'ES256'})
    #   rescue JWT::ExpiredSignature
    #     render status: :unauthorized
    #   end
    # end
  end
end
