# frozen_string_literal: true

# The SearchResult is a non-persistant object that groups models that can be
# searched.
class SearchResult < ActiveModelSerializers::Model
  attr_accessor :repositories, :organizational_units,
                :repositories_count, :organizational_units_count,
                :results_count

  # rubocop: disable Metrics/MethodLength
  def initialize(_params)
    repositories = Repository.all
    organizational_units = OrganizationalUnit.all

    repositories_count = repositories.count
    organizational_units_count = organizational_units.count

    super(repositories: repositories,
          organizational_units: organizational_units,

          repositories_count: repositories_count,
          organizational_units_count: organizational_units_count,

          results_count: [repositories_count,
                          organizational_units_count].sum)
  end
end
