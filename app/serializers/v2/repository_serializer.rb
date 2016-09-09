# frozen_string_literal: true

module V2
  # The serializer for Repositories, API version 2
  class RepositorySerializer < ApplicationSerializer
    attribute :slug
    attribute :name
    attribute :description

    link :self do
      url_for(controller: 'v2/repositories', action: 'show',
              slug: object.to_param)
    end
  end
end
