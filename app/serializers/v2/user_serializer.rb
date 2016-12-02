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
      url_for(controller: 'v2/users', action: :show, slug: object.to_param)
    end

    # This needs to be implemented properly when the teams are implemented
    has_many(:teams) do
      []
    end
  end
end
