# frozen_string_literal: true

Types::RepositoryContent = GraphQL::EnumType.define do
  name 'RepositoryContent'

  value "model"
  value "ontology"
  value "mathematical"
  value "specification"
end
