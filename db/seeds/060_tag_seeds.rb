# frozen_string_literal: true

repository = RepositoryCompound.wrap(Repository.find(slug: 'ada/fixtures'))
repository.git.create_tag('1.0', 'master')
repository.git.create_tag('1.1', 'master',
                          message: 'my first tag',
                          tagger: GitHelper.git_user(repository.owner))
