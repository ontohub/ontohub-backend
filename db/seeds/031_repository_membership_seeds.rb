# frozen_string_literal: true

# Fill ada fixtures repository

repo = Repository.first(slug: 'ada/fixtures')
repo.add_member(User.first(slug: 'bob'), 'admin')
repo.add_member(User.first(slug: 'cam'), 'write')
repo.add_member(User.first(slug: 'dan'), 'read')

# Fill top secret repository
Repository.first(slug: 'the-league-of-extraordinary-users/top-secret').
  add_member(User.first(slug: 'eva'), 'read')
