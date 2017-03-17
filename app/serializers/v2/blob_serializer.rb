# frozen_string_literal: true

module V2
  # The serializer for Repositories, API version 2
  class BlobSerializer < ApplicationSerializer
    type :blobs
    attribute :content
    attribute :encoding
    attribute :path

    link :self do
      object.url(Settings.server_url)
    end

    def id
      object.url_path
    end
  end
end
