# frozen_string_literal: true

module V2
  # Handles requests for version show operations
  class VersionController < ApplicationController
    def show
      render status: :ok,
             json: resource,
             serializer: V2::VersionSerializer
    end

    def resource
      @resource ||= Version.new(Version::VERSION)
    end
  end
end
