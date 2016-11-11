# frozen_string_literal: true

module V2
  # The serializer for Repositories, API version 2
  class NamespaceSerializer < ApplicationSerializer
    attribute :name

    link :self do
      url_for(controller: 'v2/namespaces', action: 'show',
              slug: object.to_param)
    end

    has_many :repositories do
      include_data false
      link :related do
        url_for(controller: 'v2/repositories', action: 'index',
                namespace_slug: object.to_param)
      end
    end

    def id
      object.to_param
    end
  end
end
