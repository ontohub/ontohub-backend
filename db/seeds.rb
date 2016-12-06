# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command (or created
# alongside the database with db:setup).
#
# Examples:
#
#  movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#  Character.create(name: 'Luke', movie: movies.first)

url_path_method = lambda do |user|
  V2::UsersController.resource_url_path(user)
end
%w(ada bob).each do |name|
  User.new(name: name, url_path_method: url_path_method).save
end

url_path_method = lambda do |repository|
  V2::RepositoriesController.resource_url_path(repository)
end
user_count = User.count
content_types = %w(ontology model specification)
%w(repo1 repo2 repo3 repo4).each_with_index do |name, index|
  Repository.new(owner: User.all[index % user_count],
                 name: name,
                 content_type: content_types[index % content_types.size],
                 public_access: true,
                 description: 'This is a dummy repository.',
                 url_path_method: url_path_method).save
end
