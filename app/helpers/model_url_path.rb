# frozen_string_literal: true

# resource_url_path generators
# The methods must be called exactly according to
# +resource_class.to_s.underscore+ and for each resource class there must be
# such a method.
module ModelURLPath
  extend module_function

  def organization
    lambda do |resource|
      "/#{resource.to_param}"
    end
  end

  def repository
    lambda do |resource|
      "/#{resource.to_param}"
    end
  end

  def repository_compound
    repository
  end

  def user
    lambda do |resource|
      "/#{resource.to_param}"
    end
  end
end
