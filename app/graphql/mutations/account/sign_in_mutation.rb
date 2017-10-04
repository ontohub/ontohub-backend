# frozen_string_literal: true

require 'ostruct'

module Mutations
  module Account
    SignInMutation = GraphQL::Field.define do
      type Types::User::SessionTokenType
      description 'Signs in a user'

      argument :username, !types.String do
        description "The user's name"
      end

      argument :password, !types.String do
        description "The user's password"
      end

      authorize! :create, :session

      resolve SignInResolver.new
    end

    # GraphQL mutation to sign in a user
    class SignInResolver < AbstractDeviseResolver
      # Note, that this does not directly use Devise controller actions to
      # perform the mutation. Devise's corresponding controller action, which
      # would normally be called, performs various things we don't need for an
      # API only application (including setting flash messages, rendering the
      # response, bypassing the signin). This code mirrors what is left of the
      # that action after stripping the rest away. Make sure that this code is
      # updated if Devise adds relevant code to the controller action.
      #
      # For reference, see the V2::Users::SessionsController#create and
      # https://github.com/plataformatec/devise/blob/7a44233fb9439e7cc4d1503b14f02a1d9f6da7b9/app/controllers/devise/sessions_controller.rb#L16-L22
      def call(_root, arguments, context)
        setup_devise(context)
        transform_params_for_devise(arguments)
        user = authenticate
        if user
          sign_in_and_return_token(user)
        else
          message = 'Invalid username or password.'
          context.add_error(GraphQL::ExecutionError.new(message))
        end
      end

      protected

      # Checks the request params for credentials and returns the corresponding
      # User object. +nil+ if no such User is found.
      # :nocov:
      def authenticate
        warden.authenticate(scope: :user)
      end
      # :nocov:

      def transform_params_for_devise(arguments)
        request.params[:user] = {name: arguments['username'],
                                 password: arguments['password']}
      end
    end
  end
end
