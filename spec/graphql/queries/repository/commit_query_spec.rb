# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/commit query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $commitRevision: ID!) {
      repository(id: $repositoryId) {
        commit(revision: $commitRevision) {
          authoredAt
          author {
            account {
              id
            }
            email
            name
          }
          committedAt
          committer {
            account {
              id
            }
            email
            name
          }
          id
          lsFiles
          message
          parentIds
          referenceNames
          references {
            name
            target {
              id
            }
          }
        }
      }
    }
    QUERY
  end

  let(:current_user) { create(:user) }
  let(:variables_base) { {'repositoryId' => repository.to_param} }

  let(:repository) do
    create(:repository_compound,
           public_access: false,
           owner: current_user)
  end
  before { create(:additional_commit, repository: repository) }

  let(:git) { repository.git }
  let(:commit) { git.commit(git.default_branch) }

  let(:variables_existent) do
    variables_base.merge('commitRevision' => commit.id)
  end
  let(:variables_not_existent) do
    variables_base.merge('commitRevision' => 'bad')
  end

  let(:expectation_signed_in_existent) do
    match('data' => {'repository' => {'commit' => expectation_base}})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'repository' => {'commit' => nil}})
  end
  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_not_signed_in_existent
  end

  let(:expectation_base) do
    {
      'authoredAt' => commit.authored_date.to_f,
      'author' => {
        'account' => expected_author_account,
        'email' => commit.author_email,
        'name' => commit.author_name,
      },
      'committedAt' => commit.committed_date.to_f,
      'committer' => {
        'account' => expected_committer_account,
        'email' => commit.committer_email,
        'name' => commit.committer_name,
      },
      'id' => commit.id,
      'message' => commit.message,
      'lsFiles' => git.ls_files(commit.id),
      'parentIds' => commit.parent_ids,
      'referenceNames' => commit.ref_names,
      'references' => include(
        'name' => git.default_branch,
        'target' => {'id' => commit.id}
      ),
    }
  end

  context 'with author+committer account' do
    let(:author_account) { User.first(email: commit.author_email) }
    let(:committer_account) { author_account }
    let(:expected_author_account) { {'id' => author_account.to_param} }
    let(:expected_committer_account) { expected_author_account }

    it_behaves_like 'a GraphQL query', %w(repository commit)
  end

  context 'without author+committer account' do
    let!(:author_account) { nil }
    let!(:committer_account) { nil }
    let(:expected_author_account) { nil }
    let(:expected_committer_account) { nil }

    before { User.first(email: commit.author_email).destroy }
    it_behaves_like 'a GraphQL query', %w(repository commit)
  end
end
