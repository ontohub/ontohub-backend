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

%w(ada bob).each do |name|
  User.new(name: name).save
end

namespace_count = Namespace.count
%w(repo1 repo2 repo3 repo4).each_with_index do |name, index|
  r = Repository.new(name: name, content_type: 'ontology', public_access: true)
  r.namespace = Namespace.all[index % namespace_count]
  r.save
end
