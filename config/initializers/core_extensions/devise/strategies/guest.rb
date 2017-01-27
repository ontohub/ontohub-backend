# frozen_string_literal: true

module Devise
  module Strategies
    # strategy for a user guest, sets the current user to instance of object
    class Guest < Base
      def authenticate!
        guest = Object.new
        %i(to_key authenticatable_salt).each do |method|
          guest.define_singleton_method(method) { :guest }
        end
        success! guest
      end
    end
  end
end
