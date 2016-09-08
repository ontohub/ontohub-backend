# frozen_string_literal: true

class ApplicationController < ActionController::API
  # Accept and generate JSONAPI data
  include ActionController::MimeResponds
end
