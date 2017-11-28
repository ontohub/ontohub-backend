# frozen_string_literal: true

Types::ConservativityStatusType = GraphQL::ObjectType.define do
  name 'ConservativityStatus'
  description 'A conservativity status'

  field :required, !types.String do
    description 'The required conservativity value'
  end

  field :proved, !types.String do
    description 'The proved conservativity value'
  end
end
