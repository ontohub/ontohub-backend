# frozen_string_literal: true

module V2
  # The serializer for Users, API version 2
  class OrganizationSerializer < ApplicationSerializer
    # The serializer for the relationship object
    class Relationship < ApplicationSerializer
      def id
        object.to_param
      end
    end

    attribute :name
    attribute :real_name

    def id
      object.to_param
    end

    link :self do
      object.url(Settings.server_url)
    end

    has_many(:members, serializer: V2::UserSerializer::Relationship)
  end
end
