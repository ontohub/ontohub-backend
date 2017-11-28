# frozen_string_literal: true

Types::DocumentType = GraphQL::InterfaceType.define do
  name 'Document'
  description 'A Document is a container for OMS'

  # Instead of
  # implements Types::LocIdBaseType, inherit: true
  # we need to use
  Types::LocIdBaseMethods.get(self)
  # because of https://github.com/rmosolgo/graphql-ruby/issues/1067

  field :documentLinks, !types[!Types::DocumentLinkType] do
    description 'All DocumentLinks that this Document is part of'

    argument :origin, Types::LinkOriginEnum do
      description <<~DESCRIPTION
        Specifies which end of the link the current document is. Possible values: 'source', 'target'
      DESCRIPTION
      default_value 'any'
    end

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resolve(lambda do |document, arguments, _context|
      case arguments['origin']
      when 'source'
        document.document_links_by_source_dataset
      when 'target'
        document.document_links_by_target_dataset
      else
        document.document_links_dataset
      end.order(Sequel[:document_links][:source_id],
                Sequel[:document_links][:target_id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :importedBy, !types[!Types::DocumentType] do
    description 'The documents which import this Document'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resource(lambda do |document, _arguments, _context|
      document.imported_by_dataset
    end)

    scope DocumentPolicy

    resolve(lambda do |imported_by_dataset, arguments, _context|
      imported_by_dataset.
        order(Sequel[:loc_id_bases][:loc_id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end

  field :imports, !types[!Types::DocumentType] do
    description 'The documents which are imported by this Document'

    argument :limit, types.Int do
      description 'Maximum number of entries to list'
      default_value 20
    end

    argument :skip, types.Int do
      description 'Skip the first n entries'
      default_value 0
    end

    resource(lambda do |document, _arguments, _context|
      document.imports_dataset
    end)

    scope DocumentPolicy

    resolve(lambda do |imports_dataset, arguments, _context|
      imports_dataset.
        order(Sequel[:loc_id_bases][:loc_id]).
        limit(arguments['limit'], arguments['skip'])
    end)
  end
end
