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
    resolve ->(obj, _args, _ctx) { obj.display_name }
  end
  field :organizations, types[!Types::Organization] do
    argument :limit, types.Int, 'Maximum number of repositories'
    argument :offset, types.Int, 'Skip the first n repositories'
    resolve ->(obj, args, _ctx) { obj.organizations_dataset.limit(args[:limit], args[:offset]) }
  end
  field :repositories, !types[Types::Repository] do
    argument :limit, types.Int, 'Maximum number of repositories'
    argument :offset, types.Int, 'Skip the first n repositories'
    argument :accessible, types.Boolean
    resolve ->(obj, args, _ctx) {
      if args[:accessible]
        repos = obj.accessible_repositories_dataset
      else
        repos = obj.repositories_dataset
      end
      repos.limit(args[:limit], args[:offset]) }
  end
end
