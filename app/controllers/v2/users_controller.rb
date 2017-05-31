# frozen_string_literal: true

module V2
  # Handles user show requests
  class UsersController < ResourcesWithURLController
    find_param :slug
    actions :show
    permitted_includes 'repositories'

    def show_current_user
      @resource = current_user
      if @resource
        render_resource
      else
        render status: :not_found
      end
    end
  end
end
