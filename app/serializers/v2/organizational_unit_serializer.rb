# frozen_string_literal: true

module V2
  # The serializer for Users, API version 2
  class OrganizationalUnitSerializer < ApplicationSerializer
    # The serializer for the relationship object
    class Relationship < ApplicationSerializer
      def id
        object.to_param
      end
    end
  end
end
