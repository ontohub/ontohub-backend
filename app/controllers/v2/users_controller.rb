# frozen_string_literal: true

module V2
  # Handles user show requests
  class UsersController < ResourcesWithURLController
    find_param :slug
    actions :show

    protected

    def build_resource
      super
      resource.url_path_method = lambda do |user|
        [route_prefix, user.to_param].join
      end
    end
  end
end
