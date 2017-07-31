# frozen_string_literal: true

Types::Git::BranchType = GraphQL::ObjectType.define do
  name 'Branch'
  description 'A git branch'
  interfaces [Types::Git::ReferenceType]
end
