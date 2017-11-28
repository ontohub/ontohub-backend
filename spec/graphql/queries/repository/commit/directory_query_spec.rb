# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/commit/directory query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $commitRevision: ID!, $path: ID!) {
      repository(id: $repositoryId) {
        commit(revision: $commitRevision) {
          directory(path: $path) {
            name
            path
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
  let(:variables_existent) do
    {'repositoryId' => repository.to_param,
     'commitRevision' => commit.id,
     'path' => path}
  end

  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end

  context 'on a directory' do
    let(:path) { File.dirname(file_path) }
    it_behaves_like 'a GraphQL query', %w(repository commit directory), false do
      let(:expectation_signed_in_existent) do
        directory_data =
          [{'name' => file_path.sub(%r{\A#{path}/}, ''),
            'path' => file_path}]
        match('data' => {'repository' => {'commit' => {'directory' =>
                                                         directory_data}}})
      end
    end
  end

  context 'on a file' do
    let(:path) { file_path }
    it_behaves_like 'a GraphQL query', %w(repository commit directory), false do
      let(:expectation_signed_in_existent) do
        match('data' => {'repository' => {'commit' => {'directory' => nil}}})
      end
    end
  end

  context 'on an invalid path' do
    let(:path) { "bad-#{file_path}" }
    it_behaves_like 'a GraphQL query', %w(repository commit directory), false do
      let(:expectation_signed_in_existent) do
        match('data' => {'repository' => {'commit' => {'directory' => nil}}})
      end
    end
  end
end
