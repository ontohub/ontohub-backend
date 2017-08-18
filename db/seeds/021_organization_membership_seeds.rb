# frozen_string_literal: true

# Fill seed user organization
Organization.find(slug: 'seed-user-organization').
  add_member(User.find(slug: 'ada'), 'admin')
Organization.find(slug: 'seed-user-organization').
  add_member(User.find(slug: 'bob'), 'admin')
Organization.find(slug: 'seed-user-organization').
  add_member(User.find(slug: 'cam'), 'write')
Organization.find(slug: 'seed-user-organization').
  add_member(User.find(slug: 'dan'), 'read')
Organization.find(slug: 'seed-user-organization').
  add_member(User.find(slug: 'eva'), 'read')

# Fill extraordinary organization
Organization.find(slug: 'the-league-of-extraordinary-users').
  add_member(User.find(slug: 'ada'), 'admin')
Organization.find(slug: 'the-league-of-extraordinary-users').
  add_member(User.find(slug: 'bob'), 'admin')
Organization.find(slug: 'the-league-of-extraordinary-users').
  add_member(User.find(slug: 'cam'), 'write')
Organization.find(slug: 'the-league-of-extraordinary-users').
  add_member(User.find(slug: 'dan'), 'read')
