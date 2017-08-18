# frozen_string_literal: true

# Fill ada fixtures repository
Repository.find(slug: 'ada/fixtures').
  add_member(User.find(slug: 'bob'), 'admin')
Repository.find(slug: 'ada/fixtures').
  add_member(User.find(slug: 'cam'), 'write')
Repository.find(slug: 'ada/fixtures').
  add_member(User.find(slug: 'dan'), 'read')

# Fill top secret repository

Repository.find(slug: 'the-league-of-extraordinary-users/top-secret').
  add_member(User.find(slug: 'eva'), 'read')
