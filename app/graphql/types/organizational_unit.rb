# frozen_string_literal: true

Types::OrganizationalUnit = GraphQL::InterfaceType.define do
  name 'OrganizationalUnit'

  field :id, !types.ID
  field :displayName, types.String
  field :repositories, !types[Types::Repository] do
    argument :limit, types.Int, 'Maximum number of repositories'
    argument :offset, types.Int, 'Skip the first n repositories'
    resolve ->(obj, args, _ctx) { obj.repositories_dataset.limit(args[:limit], args[:offset]) }
  end
end
