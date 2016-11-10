# frozen_string_literal: true

module V2
  # Handles user show requests
  class UsersController < ResourcesController
    find_param :slug
    actions :show
  end
end
