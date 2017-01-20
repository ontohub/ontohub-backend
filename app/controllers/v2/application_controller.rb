# frozen_string_literal: true

module V2
  # This is the base class for all API Version 2 Controllers.
  class ApplicationController < ActionController::API
    # Accept and generate JSON API data
    include ActionController::MimeResponds
    before_action :authenticate_user!
  end
end
