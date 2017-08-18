# frozen_string_literal: true

# Fill seed user organization
organization = Organization.find(slug: 'seed-user-organization')
organization.add_member(User.find(slug: 'ada'), 'admin')
organization.add_member(User.find(slug: 'bob'), 'admin')
organization.add_member(User.find(slug: 'cam'), 'write')
organization.add_member(User.find(slug: 'dan'), 'read')
organization.add_member(User.find(slug: 'eva'), 'read')

# Fill extraordinary organization
extra_organization = Organization.
  find(slug: 'the-league-of-extraordinary-users')
extra_organization.add_member(User.find(slug: 'ada'), 'admin')
extra_organization.add_member(User.find(slug: 'bob'), 'admin')
extra_organization.add_member(User.find(slug: 'cam'), 'write')
extra_organization.add_member(User.find(slug: 'dan'), 'read')
