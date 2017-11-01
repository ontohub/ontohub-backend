# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/commit/fileVersion query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $commitRevision: ID!, $path: ID!) {
      repository(id: $repositoryId) {
        commit(revision: $commitRevision) {
          fileVersion(path: $path) {
            evaluationState
            path
            commit {
              id
            }
            repository {
              id
            }
          }
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
  let(:commit) { git.commit(git.default_branch) }
  let(:file_path) { git.ls_files(commit.id).first }

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {'repositoryId' => repository.to_param,
     'commitRevision' => commit.id}
  end

  let(:variables_existent) do
    variables_base.merge('path' => file_path)
  end
  let(:variables_not_existent) do
    variables_base.merge('path' => "bad-#{file_path}")
  end

  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end

  let(:expectation_not_signed_in_not_existent) do
    expectation_not_signed_in_existent
  end

  let(:path) { file_path }
  it_behaves_like 'a GraphQL query', %w(repository commit fileVersion) do
    let(:expectation_signed_in_existent) do
      file_version_data =
        {'evaluationState' => 'not_yet_enqueued',
         'path' => file_path,
         'commit' => {'id' => commit.id},
         'repository' => {'id' => repository.to_param}}
      match('data' => {'repository' => {'commit' => {'fileVersion' =>
                                                       file_version_data}}})
    end
    let(:expectation_signed_in_not_existent) do
      match('data' => {'repository' => {'commit' => {'fileVersion' => nil}}})
    end
  end
end
