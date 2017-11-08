# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/tag query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $name: String!) {
      repository(id: $repositoryId) {
        tag(name: $name) {
          name
          target {
            id
          }
          annotation
        }
      }
    }
    QUERY
  end

  let(:repository) do
    create(:repository_compound, :not_empty,
           public_access: false,
           owner: current_user)
  end
  let(:git) { repository.git }
  let!(:tag) { create(:tag, repository: repository, message: message) }

  let(:current_user) { create(:user) }
  let(:variables_base) { {'repositoryId' => repository.to_param} }

  let(:variables_existent) { variables_base.merge('name' => tag.name) }
  let(:variables_not_existent) { variables_base.merge('name' => 'bad') }

  let(:expectation_signed_in_existent) do
    tag_data = {
      'name' => tag.name,
      'annotation' => message,
      'target' => {'id' => git.commit(tag.target).id},
    }
    match('data' => {'repository' => {'tag' => tag_data}})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'repository' => {'tag' => nil}})
  end
  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_not_signed_in_existent
  end

  context 'with annotation' do
    let(:message) { 'message' }
    it_behaves_like 'a GraphQL query', %w(repository tag)
  end

  context 'without annotation' do
    let(:message) { nil }
    it_behaves_like 'a GraphQL query', %w(repository tag)
  end
end
