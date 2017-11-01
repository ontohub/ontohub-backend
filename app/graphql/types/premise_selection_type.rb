# frozen_string_literal: true

Types::PremiseSelectionType = GraphQL::InterfaceType.define do
  name 'PremiseSelection'
  description 'A selection of premises for reasoning'

  field :id, !types.Int do
    description 'The ID of the PremiseSelection'
  end

  field :reasonerConfiguration, !Types::ReasonerConfigurationType do
    description 'The used ReasonerConfiguration'
    property :reasoner_configuration
  end

  field :selectedPremises, !types[!Types::SentenceType] do
    description 'The selected premises'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |premise_selection, arguments, _context|
      premise_selection.selected_premises_dataset.
        order(Sequel[:loc_id_bases][:loc_id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
