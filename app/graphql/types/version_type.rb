Types::VersionType = GraphQL::ObjectType.define do
  name 'Version'
  field :full, !types.String
  field :commit, !types.String
  field :tag, !types.String
  field :commits_since_tag, !types.Int
end
