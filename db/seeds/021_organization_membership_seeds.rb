# frozen_string_literal: true

# Fill seed user organization
organization = Organization.first(slug: 'seed-user-organization')
organization.add_member(User.first(slug: 'ada'), 'admin')
organization.add_member(User.first(slug: 'bob'), 'admin')
organization.add_member(User.first(slug: 'cam'), 'write')
organization.add_member(User.first(slug: 'dan'), 'read')
organization.add_member(User.first(slug: 'eva'), 'read')

# Fill extraordinary organization
extra_organization = Organization.
  find(slug: 'the-league-of-extraordinary-users')
extra_organization.add_member(User.first(slug: 'ada'), 'admin')
extra_organization.add_member(User.first(slug: 'bob'), 'admin')
extra_organization.add_member(User.first(slug: 'cam'), 'write')
extra_organization.add_member(User.first(slug: 'dan'), 'read')
