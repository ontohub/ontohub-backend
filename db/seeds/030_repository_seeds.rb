# frozen_string_literal: true

# An empty git repository cannot be kept in the ontohub-backend repository
# because git cannot handle the empty directories of an empty repository.
# As a work-around, we create it in the seeds:
empty_git_path = Rails.root.join('db/seeds/fixtures/repositories/git/empty.git')
FileUtils.rm_rf(empty_git_path.to_s) if Dir.exist?(empty_git_path)
`git init --bare #{empty_git_path}`

# Create repositories.
organization_fixtures_repo =
  RepositoryCompound.
    new(owner: Organization.first(slug: 'seed-user-organization'),
        name: 'Fixtures',
        content_type: 'model',
        public_access: true,
        description: 'This is a fixture repository from the organization.')
organization_fixtures_repo.save

ada_fixtures_repo =
  RepositoryCompound.
    new(owner: User.first(slug: 'ada'),
        name: 'Fixtures',
        content_type: 'specification',
        public_access: true,
        description: 'This is a fixture repository from the user ada.')
ada_fixtures_repo.save

bob_public_repo =
  RepositoryCompound.
    new(owner: User.first(slug: 'bob'),
        name: 'My public repository',
        content_type: 'specification',
        public_access: true,
        description: 'This is a seed repository from the user bob.')
bob_public_repo.save

cam_secret_repo =
  RepositoryCompound.
    new(owner: User.first(slug: 'cam'),
        name: 'My private repository',
        content_type: 'specification',
        public_access: false,
        description: 'This is a seed repository from the user cam.')
cam_secret_repo.save

organization_math_repo =
  RepositoryCompound.
    new(owner: Organization.first(slug: 'seed-user-organization'),
        name: 'Math',
        content_type: 'mathematical',
        public_access: true,
        description: 'This is a mathematical repository.')
organization_math_repo.save

top_secret_repo =
  RepositoryCompound.
    new(owner: Organization.first(slug: 'the-league-of-extraordinary-users'),
        name: 'Top Secret',
        content_type: 'ontology',
        public_access: false,
        description: 'This is a top secret private repository.')
top_secret_repo.save

repo_fixtures = Rails.root.join('db/seeds/fixtures/repositories')
{'git/empty.git' =>
   {name: 'mirror of empty git',
    description: 'mirror of an empty git repository',
    remote_type: 'mirror'},
 'git/with_branches.git' =>
   {name: 'fork of git with branches',
    description: 'fork of a git repository with branches',
    remote_type: 'fork'},
 'svn/custom_layout_with_commits.svn' =>
   {name: 'mirror of svn repository with custom layout and commits',
    description: 'mirror of svn repository with a custom layout and commits',
    remote_type: 'mirror'},
 'svn/empty.svn' =>
   {name: 'fork of empty svn repository',
    description: 'fork of an empty svn repository',
    remote_type: 'fork'},
 'svn/standard_layout_with_branches_with_commits.svn' =>
   {name: 'mirror of svn repository with standard layout, branches and commits',
    description:
      'mirror of a svn repository with standard layout, branches and commits',
    remote_type: 'mirror'},
 'svn/standard_layout_with_branches_without_commits.svn' =>
   {name: 'fork of svn repository with standard layout,
            branches but without commits',
    description: 'fork of an svn repository with standard layout,
                    branches but without commits',
    remote_type: 'fork'},
 'svn/standard_layout_without_branches_without_commits.svn' =>
   {name: 'mirror of svn repository with standard layout
            but without branches and commits',
    description: 'mirror of an svn repository with standard layout
                    but without branches and commits',
    remote_type: 'mirror'}}.each do |remote_path, params|
  base_params = {owner: Organization.first(slug: 'seed-user-organization'),
                 content_type: 'specification',
                 public_access: true,
                 remote_address: "file://#{repo_fixtures.join(remote_path)}"}
  repository = Repository.create(base_params.merge(params))
  RepositoryCloningJob.new.perform(repository.to_param)
end
