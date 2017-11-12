# frozen_string_literal: true

require_relative 'http_authorization.rb'

module Devise
  module Strategies
    # Strategy for API key authentication
    class ApiKey < HttpAuthorization
      def authenticate!
        api_key = ::ApiKey.
          verify(Rails.application.secrets.api_key_base, user_key)

        success! api_key if api_key
      end

      protected

      def user_key
        _strategy, token = strategy_and_token
        token
      end

      private

      def expected_strategy
        'apikey'
      end
    end
  end
end
