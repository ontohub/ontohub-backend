# frozen_string_literal: true

# Create OrganizationMemberships with all roles
roles = %w(admin write read)
User.all.zip(roles) do |p|
  Organization.first.add_member(p[0], p[1])
end
