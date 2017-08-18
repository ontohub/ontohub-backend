# frozen_string_literal: true

repository = RepositoryCompound.wrap(Repository.find(slug: 'ada/fixtures'))
repository.git.create_branch('new_feature', 'master')
