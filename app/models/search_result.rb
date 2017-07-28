# frozen_string_literal: true

# The SearchResult is a non-persistant object that groups models that can be
# searched.
class SearchResult < ActiveModelSerializers::Model
  attr_accessor :repositories, :organizational_units,
                :repositories_count, :organizational_units_count,
                :results_count

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

  # We can refactor the whole class when we drop the JSON API, for now, this
  # returns the search result in a format that graphql can work with without
  # influencing the JSON API controller
  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def to_struct(params)
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    result = OpenStruct.new
    repos = repositories.map do |repo|
      OpenStruct.new(entry: RepositoryCompound.wrap(repo), ranking: 1.0)
    end
    org_units = organizational_units.map do |org_unit|
      OpenStruct.new(entry: org_unit, ranking: 1.0)
    end

    result.entries = []
    if !params[:categories] ||
       params[:categories].empty? ||
       params[:categories].include?('repositories')
      result.entries.concat(repos)
    end
    if !params[:categories] ||
       params[:categories].empty? ||
       params[:categories].include?('organizationalUnits')
      result.entries.concat(org_units)
    end

    result.count = OpenStruct.new(
      all: [repositories_count, organizational_units_count].sum,
      repositories: repositories_count,
      organizational_units: organizational_units_count
    )
    result
  end
end
