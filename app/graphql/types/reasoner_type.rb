# frozen_string_literal: true

Types::ReasonerType = GraphQL::ObjectType.define do
  name 'Reasoner'
  description 'A Reasoning system (prover or consistency checker)'

  field :id, !types.ID do
    description 'The ID of the reasoner'
    property :slug
  end

  field :displayName, !types.String do
    description 'The human-friendly name of this reasoner'
    property :display_name
  end
end
