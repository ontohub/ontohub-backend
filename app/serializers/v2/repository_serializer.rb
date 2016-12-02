# frozen_string_literal: true

module V2
  # The serializer for Repositories, API version 2
  class RepositorySerializer < ApplicationSerializer
    # The serializer for the relationship object
    class Relationship < ApplicationSerializer
      def id
        object.to_param
      end
    end

    attribute :name
    attribute :description
    attribute :content_type
    attribute :public_access

    has_one :namespace, serializer: V2::NamespaceSerializer::Relationship do
      link :related do
        path = url_for(controller: 'v2/namespaces', action: 'show',
                       slug: object.namespace.to_param, only_path: true)
        [Settings.server_url, path].join
      end
    end

    link :self do
      object.url(Settings.server_url)
    end

    def id
      object.to_param
    end
  end
end
