# frozen_string_literal: true

Types::Session = GraphQL::ObjectType.define do
  name 'Session'

  field :token, !types.String do
    resolve ->(obj, _args, _ctx) { JWTWrapper.encode({user_id: obj.user.slug}) }
  end
  field :user, !Types::User
end
