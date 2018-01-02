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
    mutation CloneRepository($newRepository: NewRepository!, $remoteAddress: String!, $remoteType: RepositoryRemoteType!, $urlMappings: [NewUrlMapping!]!) {
      cloneRepository(data: $newRepository, remoteAddress: $remoteAddress, remoteType: $remoteType, urlMappings: $urlMappings) {
        id
        description
        contentType
        visibility
      }
    }
    QUERY
  end

  subject { result }

  context 'with a valid remote' do
    before do
      # Stub the Bringit::Wrapper
      allow(Bringit::Wrapper).
        to receive(:valid_remote?).
        and_return(true)

      allow(::Repository).
        to receive(:create).
        with('name' => repository_data['name'],
             'description' => repository_data['description'],
             'owner' => user,
             'content_type' => repository_data['contentType'],
             'public_access' => repository_data['visibility'] == 'public',
             'remote_address' => variables['remoteAddress'],
             'remote_type' => variables['remoteType']).
        and_call_original
    end
    it 'enqueues a clone-repository job' do
      expect(RepositoryCloningJob).
        to have_been_enqueued.
        with(subject['data']['cloneRepository']['id'])
    end

    it 'creates the repository' do
      expect(subject).not_to be(nil)
    end

    it 'creates the url mappings' do
      allow(UrlMapping).to receive(:create).and_call_original
      subject
      url_mappings.each do |url_mapping|
        expect(UrlMapping).
          to have_received(:create).
          with(repository_id:
                 Repository.first(slug: repository_blueprint.to_param).id,
               source: url_mapping['source'],
               target: url_mapping['target'])
      end
    end
  end

  context 'with an invalid remote' do
    before do
      # Stub the Bringit::Wrapper
      allow(Bringit::Wrapper).
        to receive(:valid_remote?).
        and_return(false)

      allow(UrlMapping).
        to receive(:create)
    end

    it 'does not enqueue a clone-repository job' do
      expect(RepositoryCloningJob).
        not_to have_been_enqueued
    end

    it 'adds a GraphQL error' do
      expect(subject.to_h).
        to match('data' => {'cloneRepository' => nil},
                 'errors' =>
                   [include('message' =>
                     /remote_address: ".*" is not a git or svn repository/)])
    end

    it 'repository was not created' do
      expect(UrlMapping).
        not_to have_received(:create)
    end
  end
end
