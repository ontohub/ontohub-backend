# frozen_string_literal: true

module V2
  # The serializer for Repositories, API version 2
  class RepositoryCompoundSerializer < ApplicationSerializer
    # The serializer for the relationship object
    class Relationship < ApplicationSerializer
      type :repositories
      def id
        object.to_param
      end
    end

    type :repositories
    attribute :name
    attribute :description
    attribute :content_type
    attribute :public_access

    has_one :owner,
      serializer: V2::OrganizationalUnitSerializer::Relationship do
      link :related do
        object.owner.url(Settings.server_url)
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
