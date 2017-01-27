# frozen_string_literal: true

module Devise
  module Strategies
    class Guest < Base
      def authenticate!
        #binding.pry
        guest = Object.new
        %i(to_key authenticatable_salt).each do |method|
          guest.define_singleton_method(method) { :guest }
        end
        success! guest
      end
    end
  end
end
