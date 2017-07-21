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
      # FIXME: Remove this and the other if when switching to the GraphQL API.
      if %w(create update destroy).include?(action_name)
        return
      end
      if %w(index create).include?(action_name)
        authorize(controller_name.classify.constantize)
      else
        authorize(resource) if resource
      end
    rescue Pundit::NotAuthorizedError
      if [RepositoryCompound].include?(resource.class)
        render status: :not_found
      else
        render status: :unauthorized
      end
    end
  end
end
