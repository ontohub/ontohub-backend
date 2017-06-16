# frozen_string_literal: true

Types::Organization = GraphQL::ObjectType.define do
  interfaces [Types::OrganizationalUnit]
  name 'Organization'
  field :id, !types.ID do
    description 'ID of the organization'
    resolve ->(obj, _args, _ctx) { obj.slug }
  end
  field :displayName, types.String do
    resolve ->(obj, _args, _ctx) { obj.display_name }
  end
  field :description, types.String
  field :members, types[!Types::User] do
    resolve ->(obj, _args, _ctx) { obj.members }
  end
end
