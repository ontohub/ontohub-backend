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
Organization.new(name: 'Seed User Organization',
                 url_path_method: url_path_method).save
organization = Organization.first
User.all do |user|
  organization.add_member(user)
end

# Create repositories.
url_path_method = lambda do |repository|
  V2::RepositoriesController.resource_url_path(repository)
end
owner_count = OrganizationalUnit.count
content_types = %w(ontology model specification mathematical)
(0..(2 * owner_count - 1)).each do |repo_index|
  owner = OrganizationalUnit.find(id: repo_index % owner_count + 1)
  repository =
    RepositoryCompound.
      new(owner: owner,
          name: "repo#{repo_index}",
          content_type: content_types[repo_index % content_types.size],
          public_access: true,
          description: 'This is a dummy repository.',
          url_path_method: url_path_method)
  repository.save

  user = owner.is_a?(Organization) ? owner.members.first : owner
  (1..5).each do |file_index|
    path = "#{file_index}_test.txt"
    path = "subdir_#{file_index}/#{path}" if file_index <= 2
    Blob.new(repository: repository, user: user, branch: 'master', path: path,
             content: "test file ##{file_index}", encoding: 'plain',
             commit_message: "Add #{path}.").create
  end
end
