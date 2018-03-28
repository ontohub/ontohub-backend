class SearchResolver
  attr_reader :query
  def initialize(query) do
    @query = query
  end

  def call
    #[::Index::RepositoryIndex::Repository,
    # ::Index::OrganizationIndex::Organization,
    # ::Index::UserIndex::User].map do |klass|
    #   klass.query(match: {name: query}).entries.map do |entry|
    #    entry.id
    #  end
    #end
    
  end
end
