# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'cloneRepository mutation' do
  let!(:user) { create :user }

  let(:repository_blueprint) do
    repo = build :repository, :mirror, owner: user
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

  let(:context) { {current_user: user} }
  let(:variables) do
    {'newRepository' => repository_data,
     'remoteAddress' => repository_blueprint.remote_address,
     'remoteType' => repository_blueprint.remote_type,
     'urlMappings' => url_mappings}
  end

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation CloneRepository($newRepository: NewRepository!, $remoteAddress: String!, $remoteType: RepositoryRemoteTypeEnum!, $urlMappings: [NewUrlMapping!]!) {
      cloneRepository(data: $newRepository, remoteAddress: $remoteAddress, remoteType: $remoteType, newUrlMappings: $urlMappings) {
        id
        description
        contentType
        visibility
      }
    }
    QUERY
  end

  subject { result }

  context 'remote is valid' do
    before do
      # Stub the Bringit::Wrapper
      allow(Bringit::Wrapper).
        to receive(:valid_remote?).
        and_return(true)
    end
    it 'enqueues a clone-repository job' do
      expect(RepositoryCloningJob).
        to have_been_enqueued.
        with(subject['data']['cloneRepository']['id'])
    end
  end

  context 'remote is invalid' do
    before do
      # Stub the Bringit::Wrapper
      allow(Bringit::Wrapper).
        to receive(:valid_remote?).
        and_return(false)
    end
    it 'enqueues a clone-repository job' do
      # binding.pry
      expect(RepositoryCloningJob).
        not_to have_been_enqueued
    end
  end
end
