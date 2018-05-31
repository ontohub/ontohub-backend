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
        
      )
    )
d  end
end
