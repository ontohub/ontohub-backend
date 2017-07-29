# frozen_string_literal: true

Types::TimeType = GraphQL::ScalarType.define do
  name 'Time'
  description 'Represents the time'

  coerce_input ->(value, _context) { Time.at(Float(value)) }
  coerce_result ->(value, _context) { value.to_f }
end
