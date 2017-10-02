# frozen_string_literal: true

Types::LinkOriginEnum = GraphQL::EnumType.define do
  name 'LinkOrigin'
  description 'Specifies which end of the link the current object is'

  value 'any', 'The current object is any end of the link'
  value 'source', 'The current object is the source of the link'
  value 'target', 'The current object is the target of the link'
end
