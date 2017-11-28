# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/commit/diff query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $commitRevision: ID!) {
      repository(id: $repositoryId) {
        commit(revision: $commitRevision) {
          diff {
            deletedFile
            diff
            lineCount
            newFile
            newMode
            newPath
            oldMode
            oldPath
            renamedFile
          }
        }
      }
    }
    QUERY
  end

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {'repositoryId' => repository.to_param,
     'commitRevision' => commit.id}
  end

  let(:repository) do
    create(:repository_compound, :not_empty,
           public_access: false,
           owner: current_user)
  end
  let(:git) { repository.git }
  let!(:commit) { git.commit(git.default_branch) }

  it_behaves_like 'a GraphQL query', %w(repository commit diff), false do
    let(:variables_existent) { variables_base }
    let(:expectation_signed_in_existent) do
      match('data' => {'repository' => {'commit' => {'diff' => match(
        include('deletedFile' => false,
                'diff' => match(%r{--- /dev/null\s*^\+\+\+}),
                'lineCount' => be > 0,
                'newFile' => true,
                'newMode' => /[0-7]{6}/,
                'newPath' => be_present,
                'oldMode' => '0',
                'oldPath' => be_present,
                'renamedFile' => false)
      )}}})
    end
    let(:expectation_not_signed_in_existent) do
      match('data' => {'repository' => nil})
    end
  end
end
