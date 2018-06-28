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
    indices.map do |index|
      index.query(multi_match: {query: query,
                                fuzziness: 'auto',
                                fields: %i(
                                  display_name
                                  slug
                                  name
                                  description
                                )}).entries
    end.flatten
  end

  def map_categories_to_indices(categories)
    if categories.blank?
      [::Index::RepositoryIndex::Repository,
       ::Index::OrganizationIndex::Organization,
       ::Index::UserIndex::User]
    else
      reduce_categories(categories)
    end
  end

  # rubocop:disable Metrics/MethodLength
  def reduce_categories(categories)
    # rubocop:enable Metrics/MethodLength
    categories.reduce([]) do |indices, category|
      case category
      when 'organizationalUnits'
        indices + [::Index::OrganizationIndex::Organization,
                   ::Index::UserIndex::User]
      when 'repositories'
        indices + [::Index::RepositoryIndex::Repository]
      else
        indices
      end
    end
  end

  def organizational_units_count(result)
    result.count do |element|
      elem = element._data['_index']
      elem == 'organization' || elem == 'user'
    end
  end

  def repositories_count(result)
    result.count do |element|
      element._data['_index'] == 'repository'
    end
  end

  # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
  def map_entries_to_models(result)
    # rubocop:enable Metrics/MethodLength, Metrics/AbcSize
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
