# frozen_string_literal: true

Types::GitActionEnum = GraphQL::EnumType.define do
  name 'GitAction'
  description 'An action in git'

  value 'pull', 'Pull from a repository'
  value 'push', 'Push to a repository'
end
