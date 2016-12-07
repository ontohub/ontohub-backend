# frozen_string_literal: true

module V2
  # Handles user show requests
  class OrganizationalUnitsController < ReroutingController
    def show
      send_controller_action(:show,
                             OrganizationalUnit.find(slug: params[:slug]))
    end
  end
end
