# frozen_string_literal: true

module V2
  module Users
    # Handles registration, editing and deletion of Users
    class AccountController < Devise::RegistrationsController
      include AccountMethods

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

      # This is overwriting the original method.
      def sign_up_params
        parse_params(only: %i(display_name name email password))
      end

      def account_update_params
        parse_params(only: %i(display_name email password current_password))
      end

      def parse_params(**options)
        ActiveModelSerializers::Deserialization.
          jsonapi_parse!(params, **options)
      end

      def captcha
        params.fetch(:data, {}).fetch(:attributes, {}).fetch(:captcha, nil)
      end

      # Disable responding (rendering) of the parent class.
      # This should be done manually here.
      def respond_with(*args); end
    end
  end
end
