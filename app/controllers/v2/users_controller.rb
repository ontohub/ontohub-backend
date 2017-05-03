# frozen_string_literal: true

module V2
  # Handles user show requests
  class UsersController < ResourcesWithURLController
    find_param :slug
    actions :show
    permitted_includes 'repositories'

    def show_by_name
      user = User.find(slug: params[:name].parameterize)
      if user
        render status: :ok, json: user, serializer: V2::UserSerializer
      else
        render status: :not_found
      end
    end
  end
end
