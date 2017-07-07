# frozen_string_literal: true

Types::RepositoryContentTypeEnum = GraphQL::EnumType.define do
  name 'RepositoryContentType'
  description 'Possible types of repositories'

  value 'ontology'
  value 'model'
  value 'specification'
  value 'mathematical'
end
