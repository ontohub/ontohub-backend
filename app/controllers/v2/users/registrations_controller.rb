# frozen_string_literal: true

module V2
  module Users
    # Handles registration, editing and deletion of Users
    class RegistrationsController < Devise::RegistrationsController
      # POST /resource
      def create
        super
        render status: :created, json: resource, serializer: UserSerializer
      rescue Sequel::ValidationFailed
        render status: :unprocessable_entity,
               json: resource,
               serializer: ActiveModel::Serializer::ErrorSerializer
      end

      # PATCH /resource
      def update
        super
        if resource.is_a?(resource_class)
          render status: :created, json: resource, serializer: UserSerializer
        else
          render status: :not_found
        end
      rescue Sequel::ValidationFailed
        render status: :unprocessable_entity,
               json: resource,
               serializer: ActiveModel::Serializer::ErrorSerializer
      end

      # DELETE /resource
      def destroy
        if resource
          resource.destroy
          render status: :no_content
        else
          render status: :not_found
        end
      end

      protected

      # Build a devise resource passing in the session. Useful to move
      # temporary session data to the newly created user.
      # This is overwriting the original method.
      def build_resource(hash = nil)
        self.resource = resource_class.new_with_session(hash || {}, session)
        resource.url_path_method = ->(user) { "/users/#{user.to_param}" }
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
