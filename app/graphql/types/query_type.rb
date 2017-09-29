# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Types::QueryType = GraphQL::ObjectType.define do
  # rubocop:enable Metrics/BlockLength
  name 'Query'
  description 'Base query type'

  field :me, Types::UserType do
    description 'The currently signed in user'

    resolve(lambda do |_root, _arguments, context|
      context[:current_user]
    end)
  end

  field :organizationalUnit, Types::OrganizationalUnitType do
    description 'The organizational unit for the given ID'

    argument :id, !types.ID, as: :slug do
      description 'ID of the organizational unit'
    end

    resolve(lambda do |_root, arguments, _context|
      OrganizationalUnit.find(slug: arguments[:slug])
    end)
  end

  field :repository, Types::RepositoryType do
    description 'The repository for the given ID'

    argument :id, !types.ID, as: :slug do
      description 'ID of the repository'
    end

    authorize :show

    resource!(lambda do |_root, arguments, _context|
      RepositoryCompound.find(slug: arguments[:slug])
    end)

    resolve ->(repo, _arguments, _context) { repo }
  end

  field :search, !Types::SearchResultType do
    description 'Search Ontohub'

    argument :query, !types.String do
      description 'The query string'
    end

    resolve(->(_root, _arguments, _context) { :ok })
  end

  field :version, !Types::VersionType do
    description 'The version of the running backend'

    resolve(lambda do |_root, _arguments, _context|
      Version.new(Version::VERSION)
    end)
  end
end
