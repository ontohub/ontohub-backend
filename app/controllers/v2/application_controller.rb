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

    # rubocop: disable Metrics/PerceivedComplexity
    # rubocop: disable Metrics/MethodLength
    # rubocop: disable Metrics/AbcSize
    def authorize_resource
      # rubocop: enable Metrics/PerceivedComplexity
      # rubocop: enable Metrics/MethodLength
      # rubocop: enable Metrics/AbcSize
      # FIXME: Remove this and the other if when switching to the GraphQL API.
      return if %w(create update destroy).include?(action_name)
      if %w(index create).include?(action_name)
        authorize(controller_name.classify.constantize)
      elsif resource
        authorize(resource)
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
