# frozen_string_literal: true

module Devise
  module Strategies
    # strategy for login with jwt
    class JsonWebToken < Base
      def valid?
        return false unless request.headers['Authorization'].present?

        strategy, _token = strategy_and_token
        (strategy || '').casecmp 'bearer'
      end

      def authenticate!
        return fail! unless claims
        return fail! unless claims.key?('user_id')

        success! User.find(users__id: claims['user_id'])
      end

      protected

      def strategy_and_token
        @strategy_and_token ||= request.headers['Authorization'].split(' ')
      end

      def claims
        _strategy, token = strategy_and_token
        JWTWrapper.decode(token)
      end
    end
  end
end
