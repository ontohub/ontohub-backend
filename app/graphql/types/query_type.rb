# frozen_string_literal: true

Types::QueryType = GraphQL::ObjectType.define do
  name 'Query'
  # Add root-level fields here.
  # They will be entry points for queries on your schema.

  # TODO: remove me
  field :testField, types.String do
    description 'An example field added by the generator'
    resolve ->(_obj, _args, _ctx) { 'Hello World!' }
  end

  field :version, !Types::Version do
    resolve ->(_obj, _args, _ctx) { Version.new(Version::VERSION) }
  end

  field :me, Types::User do
    resolve ->(_obj, _args, ctx) { ctx[:current_user] }
  end

  field :organizationalUnit do
    type Types::OrganizationalUnit
    argument :id, !types.ID
    resolve ->(_obj, args, _ctx) { OrganizationalUnit.find(slug: args['id']) }
  end

  field :user do
    type Types::User
    argument :id, !types.ID
    description 'Get a single user with the given id'
    resolve ->(_obj, args, _ctx) { User.find(slug: args['id']) }
  end

  field :organization do
    type Types::Organization
    argument :id, !types.ID
    description 'Get a single organization with the given id'
    resolve ->(_obj, args, _ctx) { Organization.find(slug: args['id']) }
  end
end
