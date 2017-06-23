# frozen_string_literal: true

# Create users.
[{name: 'ada', display_name: 'Ada Lovelace'}, {name: 'bob'}].each do |userinfo|
  user = User.new(userinfo.
                  merge(email: "#{userinfo[:name]}@example.com",
                        role: 'user',
                        url_path_method: url_path_method))
  user.password = 'changemenow'
  user.confirmed_at = Time.now
  user.save
end

# Create organizations.
Organization.new(name: 'seed-user-organization',
                 display_name: 'Seed User Organization',
                 description: 'All users that are created in the seeds',
                 url_path_method: ModelURLPath.organization).save
organization = Organization.first
User.all do |user|
  organization.add_member(user)
end

# Create repositories.
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
          url_path_method: ModelURLPath.repository)
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
