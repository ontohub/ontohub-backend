# frozen_string_literal: true

require 'ostruct'

# Returns a search result to the GraphQL API
class SearchResolver
  def call(root, arguments, _context)
    result = search_index(root[:query], create_indices(arguments[:categories]))
    OpenStruct.new(
      entries: create_entries(result),
      count: OpenStruct.new(
        all: result.size,
        organizational_units: all_organizational_units(result),
        repositories: all_repositories(result)
      )
    )
  end

  def search_index(query, indices)
    result = indices.map do |index|
      index.query(multi_match: {query: query,
                                fuzziness: 'auto',
                                fields: %i(
                                  display_name
                                  slug
                                  name
                                  description
                                )}).entries
    end
    result.flatten
  end

  def create_indices(categories)
    if categories.blank?
      [::Index::RepositoryIndex::Repository,
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
      indices.flatten
    end
  end

  def all_organizational_units(result)
    search_result = 0
    result.each do |element|
      elem = element._data['_index']
      search_result += 1 if elem == 'user' || elem == 'organization'
    end
    search_result
  end

  def all_repositories(result)
    search_result = 0
    result.each do |element|
      elem = element._data['_index']
      search_result += 1 if elem == 'repository'
    end
    search_result
  end

  def create_entries(result)
    result.map do |element|
      OpenStruct.new(
        ranking: element._data['_score'],
        entry:
        if element._data['_type'] == 'user'
          User.first(slug: element.attributes['slug'])
        elsif element._data['_type'] == 'repository'
          Repository.first(slug: element.attributes['slug'])
        else
          Organization.first(slug: element.attributes['slug'])
        end
      )
    end
  end
end
