# frozen_string_literal: true

Types::LocIdBaseType = GraphQL::InterfaceType.define do
  name 'LocIdBase'
  description 'An object with a Loc/Id'

  Types::LocIdBaseMethods.get(self)
end
