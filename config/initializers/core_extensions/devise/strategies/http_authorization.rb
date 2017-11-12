# frozen_string_literal: true

module Devise
  module Strategies
    # Strategy for HTTP authentication header
    class HttpAuthorization < Base
      def valid?
        return false if request.headers['HTTP_AUTHORIZATION'].blank?

        strategy, _token = strategy_and_token
        (strategy || '').casecmp(expected_strategy).zero?
      end

      # Implement this in the subclasses
      def authenticate!; end

      protected

      def strategy_and_token
        @strategy_and_token ||= request.headers['HTTP_AUTHORIZATION'].split(' ')
      end

      private

      # Implement this in the subclasses
      def expected_strategy; end
    end
  end
end
