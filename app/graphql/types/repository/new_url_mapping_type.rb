# frozen_string_literal: true

Types::Repository::NewUrlMappingType = GraphQL::InputObjectType.define do
  name 'NewUrlMapping'
  description 'Data for a new url mapping'

  argument :source, !types.String do
    description 'The search substring of the URL'
  end
  argument :target, !types.String do
    description 'The replacement string of the URL'
  end
end
