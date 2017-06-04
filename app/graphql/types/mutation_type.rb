# frozen_string_literal: true

Types::MutationType = GraphQL::ObjectType.define do
  name 'Mutation'

  Session = Struct.new(:user)

  field :signIn, Types::Session do
    argument :username, !types.String
    argument :password, !types.String
    resolve ->(_obj, args, _ctx) do
      user = User.find(slug: args[:username])
      if user && user.valid_password?(args[:password])
        Session.new(user)
      end
    end
  end
end
