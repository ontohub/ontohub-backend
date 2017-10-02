# frozen_string_literal: true

Types::DocumentType = GraphQL::InterfaceType.define do
  name 'Document'
  description 'A Document is a container for OMS'

  field :locId, !types.ID do
    description 'The Loc/Id of the document'
    property :loc_id
  end

  field :documentLinks, !types[!Types::DocumentLinkType] do
    description 'All DocumentLinks that this Document is part of'

    argument :origin, Types::LinkOriginEnum do
      description <<~DESCRIPTION
        Specifies which end of the link the current document is. Possible values: 'source', 'target'
      DESCRIPTION
      default_value 'any'
    end

    resolve(lambda do |document, arguments, _context|
      case arguments['origin']
      when 'source'
        document.document_links_by_source
      when 'target'
        document.document_links_by_target
      else
        document.document_links
      end
    end)
  end
end
