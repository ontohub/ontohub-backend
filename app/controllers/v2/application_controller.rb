# frozen_string_literal: true

module V2
  # This is the base class for all API Version 2 Controllers.
  class ApplicationController < ActionController::API
    # Accept and generate JSON API data
    include ActionController::MimeResponds
    include Pundit
    before_action :current_user
    before_action :authorize_resource

    protected

    def authorize_resource
      authorize(resource || controller_name.classify.constantize)
    rescue Pundit::NotAuthorizedError
      render status: :unauthorized
    end
  end
end
