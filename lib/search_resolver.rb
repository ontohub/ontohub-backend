# frozen_string_literal: true

require 'ostruct'

# Returns a search result to the GraphQL API
class SearchResolver
  def call(_root, arguments, _context)
    query = arguments[:query]
    result = [::Index::RepositoryIndex::Repository,
              ::Index::OrganizationIndex::Organization,
              ::Index::UserIndex::User].map do |index|
      index.query(bool: {should: [
                    {match: {display_name: query}},
                    {match: {slug: query}},
                    {match: {name: query}},
                    {match: {description: query}},
                  ]}).entries
    end
    result = result.flatten
    graphQLResult = OpenStruct.new(
      global: OpenStruct.new(
        entries: createEntries(result)
        count: OpenStruct.new(
          all: result.size,
          organizationalUnits: allOrganizationalUnits(result),
          repositories: allRepositories(result)
        )
      )
    )
  end

  private
  def allOrganizationalUnits(result)
    search_result = 0
    result.each do |element|
      elem = element._data["_index"]
      if elem == 'user' || elem == 'organization'
        search_result+=1
      end
    end
    search_result
  end

  private
  def allRepositories(result)
    search_result = 0
    result.each do |element|
      elem = element._data["_index"]
      if elem == 'repository'
        search_result+=1
      end
    end
    search_result
  end

  private
  def createEntries(result)
    entries = []
    result.each do |element|
      entries.append(
        OpenStruct.new(
          ranking: element._data["score"]
          entry: if element._data["_type"] == 'user'
            User.first(slug: element.attributes["slug"])
          elsif element._data["_type"] == 'repository'
            Repostiroy.first(slug: element.attributes["slug"])
          else
            Organization.first(slug: element.attributes["slug"])
          end
        )
      )
    end
    entries
  end
end
