# frozen_string_literal: true

Types::User = GraphQL::ObjectType.define do
  interfaces [Types::OrganizationalUnit]
  name 'User'
  field :id, !types.ID do
    description 'ID of the user'
    resolve ->(obj, _args, _ctx) { obj.slug }
  end
  field :email, types.String
  field :emailHash, !types.String do
    description 'MD5 hash of the email address'
    resolve ->(obj, _args, _ctx) { Digest::MD5.hexdigest(obj.email) }
  end
  field :displayName, types.String do
    resolve ->(obj, _args, _ctx) { obj.name }
  end
  field :organizations, types[!Types::Organization] do
    resolve ->(obj, _args, _ctx) { obj.organizations }
  end
end
