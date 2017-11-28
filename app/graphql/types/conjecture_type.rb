# frozen_string_literal: true

Types::ConjectureType = GraphQL::InterfaceType.define do
  name 'Conjecture'
  description 'A conjecture'

  Types::ConjectureMethods.get(self)
end
