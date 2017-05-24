# frozen_string_literal: true

module V2
  module Users
    # Handles registration, editing and deletion of Users
    class RegistrationsController < Devise::RegistrationsController
      include ::Recaptcha::Verify

      def create
        super
        render status: :created, json: resource, serializer: UserSerializer
      rescue Sequel::ValidationFailed
        render status: :unprocessable_entity,
               json: resource,
               serializer: ActiveModel::Serializer::ErrorSerializer
      end

      def update
        return render status: :unauthorized unless current_user
        super
        if resource.modified? # Resource could not be saved in +super+
          render status: :unprocessable_entity,
                json: resource,
                serializer: ActiveModel::Serializer::ErrorSerializer
        else
          render status: :ok, json: resource, serializer: UserSerializer
        end
      end

      def destroy
        resource.destroy
        render status: :no_content
      end

      protected

      # Build a devise resource passing in the session. Useful to move
      # temporary session data to the newly created user.
      # This is overwriting the original method.
      def build_resource(hash = nil)
        self.resource = resource_class.new_with_session(hash || {}, session)
        resource.url_path_method = ->(user) { "/users/#{user.to_param}" }
        attributes = params['data']['attributes']
        captcha = attributes['captcha'] if attributes
        return if verify_recaptcha(model: resource,
                                   attribute: :captcha,
                                   response: captcha)
        # +verify_recaptcha+ is always +true+ in the test environment
        # :nocov:
        raise Sequel::ValidationFailed
        # :nocov:
      end

      # This is overwriting the original method.
      def sign_up_params
        parse_params(only: %i(real_name name email password))
      end

      def account_update_params
        parse_params(only: %i(real_name email password current_password))
      end

      def parse_params(**options)
        ActiveModelSerializers::Deserialization.
          jsonapi_parse!(params, **options)
      end

      # Disable responding (rendering) of the parent class.
      # This should be done manually here.
      def respond_with(*args); end
    end
  end
end
