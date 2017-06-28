# frozen_string_literal: true

Types::Input::UserChangesetType = GraphQL::InputObjectType.define do
  name 'UserChangeset'
  description <<~DESCRIPTION
    Contains all fields of a user account that can be changed
  DESCRIPTION

  argument :displayName, types.String, as: :display_name do
    description 'The name of the user'
  end
  argument :email, types.String do
    description 'The email address of the user'
  end
  argument :password, types.String do
    description 'The password of the user'
  end
end
