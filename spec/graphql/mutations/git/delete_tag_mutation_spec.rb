# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'deleteTag mutation' do
  let!(:repository) { create :repository_compound, :not_empty }
  let(:name) { 'v.1.0' }
  let(:name_argument) { name }
  let(:revision) { 'master' }

  let(:context) {}
  let(:variables) do
    {'repositoryId' => repository.to_param,
     'name' => name_argument,
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
    mutation ($repositoryId: ID!, $name: String!) {
      deleteTag(repositoryId: $repositoryId, name: $name)
    }
    QUERY
  end

  subject { result }

  before do
    create(:tag, name: name, revision: revision, repository: repository)
  end

  context 'Successful deletion' do
    it 'returns true' do
      expect(subject['data']['deleteTag']).to be(true)
    end

    it 'deletes the tag' do
      subject
      expect(repository.git.tag_names).not_to include(name)
    end
  end

  context 'Unsuccessful' do
    let(:name_argument) { "not_the_#{name}" }
    it 'returns true' do
      expect(subject['data']['deleteTag']).to be(true)
    end

    it 'returns no error' do
      expect(subject['errors']).to be(nil)
    end

    it 'does not delete the tag' do
      subject
      expect(repository.git.tag_names).to include(name)
    end
  end
end
