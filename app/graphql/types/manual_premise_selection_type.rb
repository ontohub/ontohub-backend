# frozen_string_literal: true

Types::ManualPremiseSelectionType = GraphQL::ObjectType.define do
  name 'ManualPremiseSelection'
  description 'A PremiseSelection whose premises were selected by hand'

  implements Types::PremiseSelectionType, inherit: true
end
