# frozen_string_literal: true

# The SearchResult is a non-persistant object that groups models that can be
# searched.
class SearchResult
  include ActiveModel::Model

  attr_reader :count, :entries
  attr_accessor :repositories, :organizational_units,
                :repositories_count, :organizational_units_count,
                :results_count

  def initialize(params)
    repositories = Repository.all
    organizational_units = OrganizationalUnit.all

    repositories_count = repositories.count
    organizational_units_count = organizational_units.count

    super(repositories: repositories,
          organizational_units: organizational_units,

          repositories_count: repositories_count,
          organizational_units_count: organizational_units_count,

          results_count: [repositories_count, organizational_units_count].sum)

    fill_entries_and_count(params)
  end

  protected

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def fill_entries_and_count(params)
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
    repos = repositories.map do |repo|
      OpenStruct.new(entry: RepositoryCompound.wrap(repo), ranking: 1.0)
    end
    org_units = organizational_units.map do |org_unit|
      OpenStruct.new(entry: org_unit, ranking: 1.0)
    end

    @entries = []
    if params[:categories].blank? ||
       params[:categories].include?('repositories')
      entries.concat(repos)
    end
    if params[:categories].blank? ||
       params[:categories].include?('organizationalUnits')
      entries.concat(org_units)
    end

    @count = OpenStruct.new(
      all: [repositories_count, organizational_units_count].sum,
      repositories: repositories_count,
      organizational_units: organizational_units_count
    )
  end
end
