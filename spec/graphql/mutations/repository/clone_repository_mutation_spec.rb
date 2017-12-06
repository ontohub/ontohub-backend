# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'createRepository mutation' do
  let!(:user) { create :user }
  
  let(:repository_blueprint) do
    repo = build :repository, owner: user :mirror
    repo.send(:set_slug)
    repo
  end

  let(:url_mappings) do
    build_list(:url_mapping, 2).map do |url_mapping| 
      {'source' => url_mapping.source, 
       'target' => url_mapping.target}
    end
  end

  let(:repository_data) do
    repo = repository_blueprint.values.
      slice(:name, :description, :content_type, :public_access).
      transform_keys { |k| k.to_s.camelize(:lower) }
    repo['visibility'] = repo['publicAccess'] ? 'public' : 'private'
    repo.delete('publicAccess')
    repo['owner'] = user.to_param
    repo
  end

  end

  let(:context) { {current_user: user} }
  let(:variables) { {'data' => repository_data,
                     'remoteAddress' => repository_blueprint.remote_address,
                     'type' => repository_blueprint.remote_type,
                     'urlMappings' => url_mappings} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation ($newRepository: NewRepository!, $remoteAddress: String!, $remoteType: RepositoryRemoteTypeEnum!, $urlMappings: [NewUrlMapping!]!) : Repository {
      cloneRepository(data: $newRepository, remoteAddress: $remoteAddress, type: $type, urlMappings: $urlMappings)
    }
    QUERY
  end

  subject { result }

  context 'User not signed in' do
    
  end
end
