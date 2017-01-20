module V2
  class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

    # GET /resource/sign_in
    # def new
    #   super
    # end

    # POST /resource/sign_in
    def create
      self.resource = warden.authenticate!(auth_options)
      sign_in(resource_name, resource)
      yield resource if block_given?
      if user_signed_in?
        render status: :created,
               json: generate_token,
               serializer: AuthenticationTokenSerializer
      end
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
