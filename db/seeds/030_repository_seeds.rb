# frozen_string_literal: true

# Create repositories.
organization_fixtures_repo =
  RepositoryCompound.
    new(owner: Organization.find(slug: 'seed-user-organization'),
        name: 'Fixtures',
        content_type: 'model',
        public_access: true,
        description: 'This is a fixture repository from the organization.',
        url_path_method: ModelURLPath.repository)
organization_fixtures_repo.save

ada_fixtures_repo =
  RepositoryCompound.
    new(owner: User.find(slug: 'ada'),
        name: 'Fixtures',
        content_type: 'specification',
        public_access: true,
        description: 'This is a fixture repository from the user ada.',
        url_path_method: ModelURLPath.repository)
ada_fixtures_repo.save

organization_math_repo =
  RepositoryCompound.
    new(owner: Organization.find(slug: 'seed-user-organization'),
        name: 'Math',
        content_type: 'mathematical',
        public_access: true,
        description: 'This is a mathematical repository.',
        url_path_method: ModelURLPath.repository)
organization_math_repo.save

top_secret_repo =
  RepositoryCompound.
    new(owner: Organization.find(slug: 'the-league-of-extraordinary-users'),
        name: 'Top Secret',
        content_type: 'ontology',
        public_access: false,
        description: 'This is a top secret private repository.',
        url_path_method: ModelURLPath.repository)
top_secret_repo.save
