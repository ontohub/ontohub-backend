# frozen_string_literal: true

module V2
  module Users
    # Confirmation controller confirms a user's email address
    class ConfirmationController < Devise::ConfirmationsController
      # Re-send the confirmation email to the user's email address
      def create
        super
        message =
          "A new confirmation email has been sent to #{resource.email} "\
          'if a user is registered by this email address.'
        render status: :created, json: {meta: {action: message},
                                        jsonapi: {version: '1.0'}}
      end

      # Confirm the user's email address
      def update
        # This is actually implemented in the show action of devise, but it
        # technically belongs in the PATCH/update action.
        show
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
        params.fetch(:data, {}).fetch(:attributes, {}).permit(:email)
      end

      # Disable responding (rendering) of the parent class.
      # This should be done manually in this class.
      def respond_with(*args); end
    end
  end
end
