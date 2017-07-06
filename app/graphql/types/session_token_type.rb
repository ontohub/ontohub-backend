# frozen_string_literal: true

Types::SessionTokenType = GraphQL::ObjectType.define do
  name 'SessionToken'
  description 'Data of a signed in user'

  field :jwt, !types.String do
    description 'The session token'
  end

  field :me, !Types::UserType do
    description 'The current user'
  end
end
