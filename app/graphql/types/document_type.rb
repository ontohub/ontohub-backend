# frozen_string_literal: true

Types::DocumentType = GraphQL::InterfaceType.define do
  name 'Document'
  description 'A Document is a container for OMS'

  field :locId, !types.ID do
    description 'The Loc/Id of the document'
    property :loc_id
  end

  field :documentLinksBySource, !types[!Types::DocumentLinkType] do
    description 'All DocumentLinks that this Document is the source of'
    property :document_links_by_source
  end

  field :documentLinksByTarget, !types[!Types::DocumentLinkType] do
    description 'All DocumentLinks that this Document is the target of'
    property :document_links_by_target
  end

  field :documentLinks, !types[!Types::DocumentLinkType] do
    description 'All DocumentLinks that this Document is part of'
    property :document_links
  end
end
