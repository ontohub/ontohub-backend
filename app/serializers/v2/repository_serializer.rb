# frozen_string_literal: true

module V2
  # The serializer for Repositories, API version 2
  class RepositorySerializer < ApplicationSerializer
    attribute :name
    attribute :description

    has_one :namespace, serializer: V2::NamespaceSerializer do
      link :related do
        url_for(controller: 'v2/namespaces', action: 'show',
                slug: object.to_param)
      end
    end

    link :self do
      url_for(controller: 'v2/repositories', action: 'show',
              namespace_slug: object.namespace.to_param,
              slug: object.slug)
    end

    def id
      object.slug
    end
  end
end
