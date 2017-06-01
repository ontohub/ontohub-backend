# frozen_string_literal: true

Types::Version = GraphQL::ObjectType.define do
  name 'Version'
  field :full, !types.String
  field :tag, !types.String
  field :commit, !types.String
  field :commitsSinceTag, !types.String do
    resolve ->(obj, args, ctx) { obj.commits_since_tag }
  end
end
