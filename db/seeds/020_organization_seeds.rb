# frozen_string_literal: true

Organization.
  create(name: 'seed-user-organization',
      display_name: 'Seed User Organization',
      description: 'All users that are created in the seeds').tap do |org|
  IndexingJob.perform_later('class' => 'Organization', 'id' => org.id)
end

Organization.
  create(name: 'the-league-of-extraordinary-users',
      display_name: 'The League of Extraordinary Users',
      description: 'Really fabulous, wow.').tap do |org|
  IndexingJob.perform_later('class' => 'Organization', 'id' => org.id)
end
