# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'createTag mutation' do
  let!(:user) { create :user }
  let!(:repository) { create :repository_compound }
  let(:name) { generate(:tagname) }
  let(:annotation) { Faker::Lorem.sentence }
  let(:revision) { 'master' }

  let(:context) { {current_user: user} }
  let(:variables) do
    {'repositoryId' => repository.to_param,
     'name' => name,
     'revision' => revision}
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
    mutation ($repositoryId: ID!, $name: String!, $revision: ID!, $annotation: String) {
      createTag(repositoryId: $repositoryId, name: $name, revision: $revision annotation: $annotation) {
        __typename
        name
        annotation
        target {
          __typename
          id
        }
      }
    }
    QUERY
  end

  subject { result }

  context 'Successful creation' do
    it 'returns the tag fields' do
      expect(subject['data']['createTag']).to include(
        'name' => name,
        'annotation' => nil,
        'target' => include('id' => repository.git.commit(revision).id)
      )
    end
    it 'creates the tag' do
      subject
      expect(repository.git.tag_names).to include(name)
    end

    context 'with annotation' do
      let(:variables) do
        {'repositoryId' => repository.to_param,
         'name' => name,
         'annotation' => annotation,
         'revision' => revision}
      end

      it 'returns the tag fields' do
        expect(subject['data']['createTag']).to include(
          'name' => name,
          'annotation' => annotation,
          'target' => include('id' => repository.git.commit(revision).id)
        )
      end
      it 'creates the tag' do
        subject
        expect(repository.git.tag_names).to include(name)
      end
    end
  end

  context 'Unsuccessful' do
    before do
      create(:tag, name: name, revision: revision, repository: repository)
    end

    it 'returns no data' do
      expect(subject['data']['createTag']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => include('already exists')))
    end
  end
end
