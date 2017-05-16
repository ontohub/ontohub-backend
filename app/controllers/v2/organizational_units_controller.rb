# frozen_string_literal: true

module V2
  # Handles user show requests
  class OrganizationalUnitsController < ReroutingController
    def show
      send_controller_action(:show,
                             OrganizationalUnit.find(slug: params[:slug]))
    end

    def show_by_name
      slug = params[:name].parameterize
      send_controller_action(:show,
                             OrganizationalUnit.find(slug: slug))
    end
  end
end
