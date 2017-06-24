# frozen_string_literal: true

Types::Input::UserChangesetType = GraphQL::InputObjectType.define do
  name 'UserChangeset'

  argument :displayName, types.String, nil, as: :display_name
  argument :email, types.String
  argument :password, types.String
end
