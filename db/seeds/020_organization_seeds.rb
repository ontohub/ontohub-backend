# frozen_string_literal: true

Organization.new(name: 'seed-user-organization',
                 display_name: 'Seed User Organization',
                 description: 'All users that are created in the seeds',
                 url_path_method: ModelURLPath.organization).save
organization = Organization.first
User.all do |user|
  organization.add_member(user)
end
