# frozen_string_literal: true

Types::Input::NewUserType = GraphQL::InputObjectType.define do
  name 'NewUser'
  description 'Data of a a new user that is about to sign up'

  argument :username, !types.ID, as: :name do
    description 'Name/id of the user'
  end

  argument :displayName, types.String, as: :display_name do
    description 'The name of the user'
  end
  argument :email, !types.String do
    description 'The email address of the user'
  end
  argument :password, !types.String do
    description 'The password of the user'
  end
end
