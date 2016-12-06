# frozen_string_literal: true

module V2
  # The serializer for Users, API version 2
  class UserSerializer < ApplicationSerializer
    # The serializer for the relationship object
    class Relationship < ApplicationSerializer
      def id
        object.to_param
      end
    end

    attribute :name
    attribute :real_name
    attribute :email

    def id
      object.to_param
    end

    link :self do
      object.url(Settings.server_url)
    end

    # This needs to be implemented properly when the organizations
    # are implemented
    has_many(:organizations) do
      []
    end
  end
end
