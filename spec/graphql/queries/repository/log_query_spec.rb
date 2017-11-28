# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/log query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $revision: String) {
      repository(id: $repositoryId) {
        log(revision: $revision) {
          id
        }
      }
    }
    QUERY
  end

  let(:repository) do
    create(:repository_compound, :not_empty,
           commit_count: 2,
           public_access: false,
           owner: current_user)
  end
  let(:git) { repository.git }
  let!(:commit) { git.commit(git.default_branch) }

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {
      'repositoryId' => repository.to_param,
      'revision' => git.default_branch,
    }
  end

  it_behaves_like 'a GraphQL query', %w(repository log) do
    let(:variables_existent) { variables_base }
    let(:variables_not_existent) { variables_base.merge('revision' => 'bad') }
    let(:expectation_signed_in_existent) do
      match('data' => {'repository' => {'log' => include(
        match('id' => commit.id)
      )}})
    end
    let(:expectation_signed_in_not_existent) do
      match('data' => {'repository' => {'log' => []}})
    end
    let(:expectation_not_signed_in_existent) do
      match('data' => {'repository' => nil})
    end
    let(:expectation_not_signed_in_not_existent) do
      expectation_not_signed_in_existent
    end
  end
end
