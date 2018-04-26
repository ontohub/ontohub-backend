class SearchResolver
  attr_reader :query
  def initialize(query) do
    @query = query
  end

  def call
    [::Index::RepositoryIndex::Repository,
     ::Index::OrganizationIndex::Organization,
     ::Index::UserIndex::User].map do |index|
        index.query(bool: { should: [{match: {display_name: query}}, 
          {match: {slug: query}}, {match: {name: query}},
          {match: {description: query}}]}).entries.map do |entry|
            entry.id
        end
    end
  end
end
