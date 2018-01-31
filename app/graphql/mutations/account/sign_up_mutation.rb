# frozen_string_literal: true

require 'ostruct'

module Mutations
  module Account
    SignUpMutation = GraphQL::Field.define do
      type Types::User::SessionTokenType
      description 'Signs up a user'

      argument :user, !Types::User::NewType do
        description "The new user's data"
      end

      argument :captcha, !types.String do
        description 'A reCAPTCHA token'
      end

      authorize! :create, policy: :account

      resolve SignUpResolver.new
    end

    # GraphQL mutation to sign up a user
    class SignUpResolver < AbstractDeviseResolver
      include AccountMethods

      # These are needed for the AccountMethods
      attr_reader :captcha, :sign_up_params
      attr_accessor :resource

      # Note, that this does not directly use Devise controller actions to
      # perform the mutation. Devise's corresponding controller action, which
      # would normally be called, performs various things we don't need for an
      # API only application (including setting flash messages, rendering the
      # response, bypassing the signin). This code mirrors what is left of the
      # that action after stripping the rest away. Make sure that this code is
      # updated if Devise adds relevant code to the controller action.
      #
      # For reference, see the
      # https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/registrations_controller.rb#L14-L34
      def call(_root, arguments, context)
        setup_devise(context)
        create_resource(arguments)

        return unless resource.persisted?

        if resource.active_for_authentication?
          sign_in_and_return_token(resource)
        else
          expire_data_after_sign_in!
          nil
        end
      end

      protected

      def create_resource(arguments)
        transform_params_for_devise(arguments)
        build_resource(sign_up_params)
        resource.save
      end

      def transform_params_for_devise(arguments)
        @sign_up_params = arguments['user'].to_h
        @captcha = arguments['captcha']
      end

      # This is needed for Devise's RegistrationsController#create's internals
      # to work.
      # :nocov:
      def resource_class
        User
      end
      # :nocov:
    end
  end
end
