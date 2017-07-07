# frozen_string_literal: true

Types::QueryType = GraphQL::ObjectType.define do
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

  field :version, !Types::VersionType do
    description 'The version of the running backend'

    resolve(lambda do |_root, _arguments, _context|
      Version.new(Version::VERSION)
    end)
  end
end
