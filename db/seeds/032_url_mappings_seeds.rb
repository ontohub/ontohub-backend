# frozen_string_literal: true

repository = RepositoryCompound.wrap(Repository.first(slug: 'ada/fixtures'))
UrlMapping.create(repository: repository, source: 'source1', target: 'target1')
UrlMapping.create(repository: repository, source: 'source2', target: 'target2')
