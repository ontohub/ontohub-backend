# frozen_string_literal: true

require 'ostruct'

# Returns a search result to the GraphQL API
class SearchResolver
  def call(root, arguments, _context)
    query = root[:query]
    categories = arguments[:categories]
    if categories.blank?
      indices = [::Index::RepositoryIndex::Repository,
                  ::Index::OrganizationIndex::Organization,
                  ::Index::UserIndex::User]
    else
      indices = categories.map do |category|
        case category
        when 'organizationalUnits'
          [::Index::OrganizationIndex::Organization, ::Index::UserIndex::User]
        when 'repositories'
          [::Index::RepositoryIndex::Repository]
        else
          []
        end
      end
      indices = indices.flatten
    end
    result = indices.map do |index|
      index.query(multi_match: {query: query,
                                fuzziness: 'auto',
                                fields: [
                                  :display_name,
                                  :slug,
                                  :name,
                                  :description]}).entries
    end
    result = result.flatten
    graphQLResult = OpenStruct.new(
      entries: createEntries(result),
      count: OpenStruct.new(
        all: result.size,
        organizational_units: allOrganizationalUnits(result),
        repositories: allRepositories(result)
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
    result.map do |element|
      OpenStruct.new(
        ranking: element._data["_score"],
        entry: if element._data["_type"] == 'user'
          User.first(slug: element.attributes["slug"])
        elsif element._data["_type"] == 'repository'
          Repository.first(slug: element.attributes["slug"])
        else
          Organization.first(slug: element.attributes["slug"])
        end
      )
    end
  end
end
