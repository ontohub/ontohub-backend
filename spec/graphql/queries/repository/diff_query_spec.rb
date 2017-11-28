# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/diff query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $from: ID!, $to: ID!, $paths: [String!]) {
      repository(id: $repositoryId) {
        diff(from: $from, to: $to, paths: $paths) {
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
    QUERY
  end

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {
      'repositoryId' => repository.to_param,
      'from' => "#{commit.id}~1",
      'to' => commit.id,
    }
  end

  let(:repository) do
    create(:repository_compound, :not_empty,
           commit_count: 2,
           public_access: false,
           owner: current_user)
  end
  let(:git) { repository.git }
  let!(:commit) { git.commit(git.default_branch) }
  let(:paths) { git.ls_files(commit.id) }

  it_behaves_like 'a GraphQL query', %w(repository diff) do
    let(:variables_existent) { variables_base }
    let(:variables_not_existent) { variables_base.merge('to' => 'bad') }
    let(:expectation_signed_in_existent) do
      match('data' => {'repository' => {'diff' => match(
        include('deletedFile' => false,
                'diff' => match(%r{--- /dev/null\s*^\+\+\+}),
                'lineCount' => be > 0,
                'newFile' => true,
                'newMode' => /[0-7]{6}/,
                'newPath' => paths.last,
                'oldMode' => '0',
                'oldPath' => paths.last,
                'renamedFile' => false)
      )}})
    end
    let(:expectation_signed_in_not_existent) do
      match('data' => {'repository' => nil},
            'errors' => include(include('message' =>
                                        match(/revspec.*not found/))))
    end
    let(:expectation_not_signed_in_existent) do
      match('data' => {'repository' => nil})
    end
    let(:expectation_not_signed_in_not_existent) do
      expectation_not_signed_in_existent
    end
  end
end
