# frozen_string_literal: true

require 'ostruct'
require 'rails_helper'

RSpec.describe 'Repository query' do
  let(:context) { {} }
  let(:variables) { {'id' => subject.to_param} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    query Repository($id: ID!) {
      repository(id: $id) {
        id
        name
        description
        owner {
          id
        }
        visibility
        contentType
        defaultBranch
        branches
        permissions {
          role
        }
      }
    }
    QUERY
  end

  subject { repository }

  context 'existing repository' do
    let!(:user) { create :user }
    let!(:repository) do
      create(:repository_compound, :not_empty)
    end

    let(:context) { {current_user: user} }

    before do
      repository.add_member(user, 'admin')
    end

    it 'returns the repository fields' do
      repository = result['data']['repository']
      expect(repository).to include(
        'id' => subject.to_param,
        'name' => subject.name,
        'description' => subject.description,
        'owner' => {'id' => subject.owner.to_param},
        'visibility' => subject.public_access ? 'public' : 'private',
        'contentType' => subject.content_type,
        'defaultBranch' => subject.git.default_branch,
        'branches' => match_array(subject.git.branch_names),
        'permissions' => {'role' => 'admin'}
      )
    end
  end

  context 'non-existant repository' do
    let(:repository) { OpenStruct.new(to_param: 'bad/slug') }

    it 'returns null' do
      repository = result['data']['repository']
      expect(repository).to be_nil
    end

    it 'does not return an error' do
      expect(subject['errors'] || {}).
        not_to include(include('message' => 'resource not found'))
    end
  end

  context 'private repository' do
    let!(:repository) do
      create(:repository_compound, :not_empty, :private)
    end

    it 'returns null' do
      repository = result['data']['repository']
      expect(repository).to be_nil
    end

    it 'does not return an error' do
      expect(result['errors'] || {}).
        not_to include(include('message' => 'resource not found'))
    end
  end
end
