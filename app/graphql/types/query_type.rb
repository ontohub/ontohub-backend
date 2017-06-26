# frozen_string_literal: true

Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'

  field :version, !Types::VersionType do
    description 'The version of the backend'
    resolve(lambda do |_obj, _args, _ctx|
      Version.new(Version::VERSION)
    end)
  end

  field :organizationalUnit, Types::OrganizationalUnitType do
    description 'The organizational unit for the given ID'
    argument :id, !types.ID, nil, as: :slug
    resolve(lambda do |_obj, args, _ctx|
      OrganizationalUnit.find(slug: args[:slug])
    end)
  end
end
