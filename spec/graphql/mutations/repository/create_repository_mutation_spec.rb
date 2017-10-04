# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'createRepository mutation' do
  let!(:user) { create :user }
  let(:repository_blueprint) do
    repo = build :repository, owner: user
    repo.send(:set_slug)
    repo
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
  let(:variables) { {'data' => repository_data} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation CreateRepository($data: NewRepository!) {
      createRepository(data: $data) {
        id
        description
        contentType
        visibility
      }
    }
    QUERY
  end

  subject { result }

  context 'Successful creation' do
    it 'returns the repository fields' do
      expect(subject['data']['createRepository']).to include(
        'id' => repository_blueprint.to_param,
        'description' => repository_data['description'],
        'contentType' => repository_data['contentType'],
        'visibility' => repository_data['visibility']
      )
    end
    it 'creates the git repository' do
      subject
      repository = RepositoryCompound.find(name: repository_blueprint.name)
      expect(repository.git.repo_exists?).to be(true)
    end
  end

  context 'Name is not available' do
    before do
      create :repository, owner: user, name: repository_blueprint.name
    end

    it 'returns an error' do
      expect(subject['data']['createRepository']).to be(nil)
      expect(subject['errors']).
        to include(include('message' => 'name is already taken'))
    end
  end

  context 'Not signed in' do
    let(:context) { {} }

    it 'returns an error' do
      expect(subject['data']['createRepository']).to be(nil)
      expect(subject['errors']).
        to include(include('message' => "You're not authorized to do this"))
    end
  end
end
