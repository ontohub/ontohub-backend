# frozen_string_literal: true

Organization.new(name: 'seed-user-organization',
                 display_name: 'Seed User Organization',
                 description: 'All users that are created in the seeds').save

Organization.new(name: 'the-league-of-extraordinary-users',
                 display_name: 'The Leaegue of Extraordinary Users',
                 description: 'Really fabulous, wow.').save
