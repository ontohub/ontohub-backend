# frozen_string_literal: true

Types::LibraryType = GraphQL::ObjectType.define do
  name 'Library'
  description 'A Library is a container for any number of OMS'

  implements Types::LocIdBaseType, inherit: true
  implements Types::DocumentType, inherit: true

  field :oms, !types[!Types::OMSType] do
    description 'A list of OMS in this Library'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |library, arguments, _context|
      dataset = OMS.where(document_id: library.id)
      dataset = dataset.where(loc_id: arguments['locId']) if arguments['locId']
      dataset.
        order(Sequel[:loc_id_bases][:loc_id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
