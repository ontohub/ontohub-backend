# frozen_string_literal: true

Types::Repository::UrlMappingType = GraphQL::ObjectType.define do
  name 'UrlMapping'
  description 'Search and replace pattern for URLs inside documents'

  field :id, !types.ID do
    description 'ID of the UrlMapping'
  end
  field :number, !types.Int do
    description 'Defines the sequence in which the mappings are applied'
  end
  field :source, !types.String do
    description 'The search substring of the URL'
  end
  field :target, !types.String do
    description 'The replacement string of the URL'
  end
end
