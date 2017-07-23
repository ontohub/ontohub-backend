# frozen_string_literal: true

module Devise
  module Strategies
    # strategy for login with jwt
    class JsonWebToken < Base
      def valid?
        return false unless request.headers['HTTP_AUTHORIZATION'].present?

        strategy, _token = strategy_and_token
        (strategy || '').casecmp 'bearer'
      end

      def authenticate!
        throw(:warden) unless claims&.key?('user_id')

        success! User.find(
          Sequel[:organizational_units][:slug] => claims['user_id']
        )
      end

      protected

      def strategy_and_token
        @strategy_and_token ||= request.headers['HTTP_AUTHORIZATION'].split(' ')
      end

      def claims
        _strategy, token = strategy_and_token
        JWTWrapper.decode(token)
      end
    end
  end
end
