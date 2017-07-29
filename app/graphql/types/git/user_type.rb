# frozen_string_literal: true

Types::Git::UserType = GraphQL::ObjectType.define do
  name 'GitUser'
  description 'Data of a git user'

  field :name, !types.String do
    description 'Name of the user'
  end

  field :email, !types.String do
    description 'Email address of the user'
  end

  field :account, Types::UserType do
    description 'Corresponding Ontohub account of the user'
  end
end
