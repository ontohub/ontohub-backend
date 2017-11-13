# frozen_string_literal: true

require_relative 'http_authorization.rb'

module Devise
  module Strategies
    # Strategy for JWT authorization
    class JsonWebToken < HttpAuthorization
      def authenticate!
        return unless claims&.key?('user_id')
        success! User.find(
          Sequel[:organizational_units][:slug] => claims['user_id']
        )
      end

      protected

      def claims
        return @claims if @claims
        _strategy, token = strategy_and_token
        @claims = JWTWrapper.decode(token)
      end

      private

      def expected_strategy
        'bearer'
      end
    end
  end
end
