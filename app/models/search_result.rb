# frozen_string_literal: true

# The SearchResult is a non-persistant object that groups models that can be
# searched.
class SearchResult < ActiveModelSerializers::Model
  attr_accessor :repositories, :users,
                :results_count, :repositories_count, :users_count

  def initialize(_params)
    repositories = Repository.all
    users = User.all
    repositories_count = repositories.count
    users_count = users.count
    super(repositories: repositories,
          users: users,
          repositories_count: repositories_count,
          users_count: users_count,
          results_count: [repositories_count, users_count].sum)
  end
end
