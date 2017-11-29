# frozen_string_literal: true

Types::Repository::NewUrlMappingType = GraphQL::ObjectType.define do
  name 'NewUrlMapping'
  description 'Data for a new url mapping'

  field :source, !types.String do
    description 'The search substring of the URL'
  end
  field :target, !types.String do
    description 'The replacement string of the URL'
  end
end
