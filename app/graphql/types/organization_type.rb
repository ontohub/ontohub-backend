# frozen_string_literal: true

Types::OrganizationType = GraphQL::ObjectType.define do
  name 'Organization'
  interfaces [Types::OrganizationalUnitType]

  field :id, !types.ID do
    description 'ID of the organization'
    property :slug
  end

  field :displayName, types.String do
    description 'Display name of the organization'
    property :display_name
  end

  field :description, types.String, 'Description of the organization'

  field :members, !types[Types::UserType] do
    argument :limit,
             types.Int,
             'Maximum number of members',
             default_value: 20
    argument :skip,
             types.Int,
             'Skip the first n members',
             default_value: 0
    resolve(lambda do |org, args, _ctx|
      org.members_dataset.limit(args[:limit], args[:skip])
    end)
  end
end
