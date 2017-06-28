# frozen_string_literal: true

# resource_url_paht generators
module ModelURLPath
  extend module_function
  def organization
    lambda do |resource|
      V2::OrganizationsController.resource_url_path(resource)
    end
  end
end
