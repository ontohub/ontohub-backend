# frozen_string_literal: true

Types::Git::ReferenceType = GraphQL::InterfaceType.define do
  name 'Reference'
  description 'A git reference'

  field :name, !types.String do
    description 'The name of the reference'
  end

  field :target, !Types::Git::CommitType do
    description 'The referenced commit'
    property :dereferenced_target
  end
end
