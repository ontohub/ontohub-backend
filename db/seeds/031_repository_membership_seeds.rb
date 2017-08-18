# frozen_string_literal: true

# Fill ada fixtures repository

repo = Repository.find(slug: 'ada/fixtures')
repo.add_member(User.find(slug: 'bob'), 'admin')
repo.add_member(User.find(slug: 'cam'), 'write')
repo.add_member(User.find(slug: 'dan'), 'read')

# Fill top secret repository
Repository.find(slug: 'the-league-of-extraordinary-users/top-secret').
  add_member(User.find(slug: 'eva'), 'read')
