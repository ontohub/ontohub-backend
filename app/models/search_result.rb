# frozen_string_literal: true

# The SearchResult is a non-persistant object that groups models that can be
# searched.
class SearchResult < ActiveModelSerializers::Model
  attr_accessor :repositories, :users, :organizations,
                :repositories_count, :users_count, :organizations_count,
                :results_count

  # rubocop: disable Metrics/MethodLength
  def initialize(_params)
    repositories = Repository.all
    users = User.all
    organizations = Organization.all

    repositories_count = repositories.count
    users_count = users.count
    organizations_count = organizations.count

    super(repositories: repositories,
          users: users,
          organizations: organizations,

          repositories_count: repositories_count,
          users_count: users_count,
          organizations_count: organizations_count,

          results_count: [repositories_count,
                          users_count,
                          organizations_count].sum)
  end
end
