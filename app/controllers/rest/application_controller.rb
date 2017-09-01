# frozen_string_literal: true

module Rest
  # This is the base class for all API Version 3 Controllers.
  class ApplicationController < ActionController::API
    extend DSL

    context do
      {current_user: current_user}
    end

    def no_op
      render status: :no_content
    end
  end
end
