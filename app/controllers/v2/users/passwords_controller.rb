# frozen_string_literal: true

module V2
  module Users
    # Passwords controller allows to reset a password given a token that is sent
    # to the user's email address.
    class PasswordsController < Devise::PasswordsController
      # Send a password-reset token to the user's email address
      def create
        super
        message =
          'An email with instructions to reset the password has been sent to '\
          "#{resource.email} "\
          'if a user is registered by this email address.'
        render status: :created, json: {meta: {action: message},
                                        jsonapi: {version: '1.0'}}
      end

      # No-op. Should be implemented in the frontend. This method exists such
      # that there is a correct link in the email that is sent by +create+.
      def edit; end

      # Update the password by using the token
      def update
        super
        if resource.errors.empty?
          render status: :ok, json: resource, serializer: UserSerializer
        else
          render status: :unprocessable_entity,
                 json: resource,
                 serializer: ActiveModel::Serializer::ErrorSerializer
        end
      end

      protected

      # By default, devise needs {user: {email: 'ada@example.com'}} parameters
      # and takes {email: 'ada@example.com'} out of it.
      # This method adjusts it to accept JSON API format.
      def resource_params
        params.fetch(:data, {}).fetch(:attributes, {}).
          permit(:email,
                 :password, :reset_password_token)
      end

      # Disable responding (rendering) of the parent class.
      # This should be done manually in this class.
      def respond_with(*args); end

      # Disable the reset_password_token check (before_action) for +edit+.
      def assert_reset_token_passed(*args); end

      # Disable redirecting to the login form after resetting the password.
      def after_resetting_password_path_for(*args); end
    end
  end
end
