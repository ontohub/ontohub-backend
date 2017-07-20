# frozen_string_literal: true

module V3
  # This is the base class for all API Version 3 Controllers.
  class ApplicationController < ActionController::API
    extend DSL
  end
end
