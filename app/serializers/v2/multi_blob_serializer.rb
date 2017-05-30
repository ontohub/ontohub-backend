# frozen_string_literal: true

module V2
  # The serializer for Repositories, API version 2
  class MultiBlobSerializer < ApplicationSerializer
    type :mutliblobs

    attribute :blobs

    def id
      [object.repository.to_param,
       object.branch,
       'commit-multiaction',
       object.user.to_param,
       Time.current.strftime('%Y-%m-%d-%H-%M-%S-%12N')].join('/')
    end

    def blobs
      object.decorated_file_versions.map do |decorated_file_version|
        if decorated_file_version[:action] == :removed
          removed_blob(decorated_file_version)
        else
          other_blob(decorated_file_version)
        end
      end
    end

    protected

    def removed_blob(decorated_file_version)
      {path: decorated_file_version[:path],
       applied_action: decorated_file_version[:action]}
    end

    def other_blob(decorated_file_version)
      {id: decorated_file_version[:file_version].url_path,
       path: decorated_file_version[:file_version].url_path,
       url: decorated_file_version[:file_version].url(Settings.server_url),
       applied_action: decorated_file_version[:action]}
    end
  end
end
