# frozen_string_literal: true

# Create users.
url_path_method = lambda do |resource|
  V2::UsersController.resource_url_path(resource)
end
%w(ada bob).each do |name|
  user = User.new(name: name,
                  email: "#{name}@example.com",
                  url_path_method: url_path_method)
  user.password = 'changeme'
  user.save
end

# Create organizations.
url_path_method = lambda do |resource|
  V2::OrganizationsController.resource_url_path(resource)
end
Organization.new(name: 'All Users', url_path_method: url_path_method).save
organization = Organization.first
User.all do |user|
  organization.add_member(user)
end

# Create repositories.
url_path_method = lambda do |repository|
  V2::RepositoriesController.resource_url_path(repository)
end
owner_count = OrganizationalUnit.count
content_types = %w(ontology model specification)
(0..(2 * owner_count - 1)).each do |index|
  Repository.new(owner: OrganizationalUnit.find(id: index % owner_count + 1),
                 name: "repo#{index}",
                 content_type: content_types[index % content_types.size],
                 public_access: true,
                 description: 'This is a dummy repository.',
                 url_path_method: url_path_method).save
end
