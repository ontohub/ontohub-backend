# frozen_string_literal: true

Organization.
  new(name: 'seed-user-organization',
      display_name: 'Seed User Organization',
      description: 'All users that are created in the seeds').save.tap do |org|
  IndexingJob.perform_later('class' => 'Organization', 'id' => org.id)
end

Organization.
  new(name: 'the-league-of-extraordinary-users',
      display_name: 'The League of Extraordinary Users',
      description: 'Really fabulous, wow.').save.tap do |org|
  IndexingJob.perform_later('class' => 'Organization', 'id' => org.id)
end
