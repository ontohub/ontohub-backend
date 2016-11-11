# frozen_string_literal: true

module V2
  # The serializer for Repositories, API version 2
  class RepositorySerializer < ApplicationSerializer
    attribute :name
    attribute :description
    attribute :content_type
    attribute :public_access

    has_one :namespace, serializer: V2::NamespaceSerializer do
      link :related do
        url_for(controller: 'v2/namespaces', action: 'show',
                slug: object.namespace.to_param)
      end
    end

    link :self do
      parts = object.to_param.split('/', 2)
      url_for(controller: 'v2/repositories', action: 'show',
              slug: object.to_param).
        sub(parts.join('%2F'), object.to_param)
    end

    def id
      object.to_param
    end
  end
end
