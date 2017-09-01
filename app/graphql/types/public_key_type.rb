# frozen_string_literal: true

Types::PublicKeyType = GraphQL::ObjectType.define do
  name 'PublicKey'
  description 'A SSH public key'

  field :name, !types.String do
    description 'Name of the key'
  end

  field :fingerprint, !types.String do
    description 'MD5 fingerprint of the key'
  end

  field :key, !types.String do
    description 'The actual SSH public key'
  end
end
