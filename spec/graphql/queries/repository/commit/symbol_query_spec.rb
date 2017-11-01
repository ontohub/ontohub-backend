# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/commit/symbol query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $commitRevision: ID!, $locId: ID!) {
      repository(id: $repositoryId) {
        commit(revision: $commitRevision) {
          symbol(locId: $locId) {
            fileRange {
              path
              startLine
              startColumn
              endLine
              endColumn
            }
            fileVersion {
              path
            }
            fullName
            kind
            locId
            name
            oms {
              locId
            }
            sentences {
              locId
            }
            signatures {
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
  let(:file_version) do
    create(:file_version, repository: repository, commit_sha: commit.id)
  end
  let(:document) { create(:library, file_version: file_version) }
  let(:oms) { create(:oms, document: document) }
  let!(:symbol) { create(:symbol, oms: oms, file_range: file_range) }
  let(:sentences) { create_list(:sentence, 2, oms: oms) }
  let(:signatures) { create_list(:signature, 2) }
  before do
    sentences.each { |s| symbol.add_sentence(s) }
    signatures.each { |s| s.add_symbol(symbol, false) }
  end

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {'repositoryId' => repository.to_param,
     'commitRevision' => commit.id}
  end

  let(:variables_existent) do
    variables_base.merge('locId' => symbol.loc_id)
  end
  let(:variables_not_existent) do
    variables_base.merge('locId' => "bad-#{symbol.loc_id}")
  end

  let(:expectation_signed_in_not_existent) do
    match('data' => {'repository' => {'commit' => {'symbol' => nil}}})
  end
  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end

  let(:expectation_not_signed_in_not_existent) do
    expectation_not_signed_in_existent
  end

  let(:symbol_data) do
    {
      'fileRange' => expected_file_range,
      'fileVersion' => {'path' => file_version.path},
      'fullName' => symbol.full_name,
      'kind' => symbol.symbol_kind,
      'locId' => symbol.loc_id,
      'name' => symbol.name,
      'oms' => {'locId' => oms.loc_id},
      'sentences' => match_array(sentences.map { |s| {'locId' => s.loc_id} }),
      'signatures' => match_array(signatures.map { |s| {'id' => s.id} }),
    }
  end

  context 'with fileRange' do
    let(:file_range) { create(:file_range) }
    let(:expected_file_range) do
      {
        'path' => file_range.path,
        'startLine' => file_range.start_line,
        'startColumn' => file_range.start_column,
        'endLine' => file_range.end_line,
        'endColumn' => file_range.end_column,
      }
    end

    it_behaves_like 'a GraphQL query', %w(repository commit symbol) do
      let(:expectation_signed_in_existent) do
        match('data' => {'repository' => {'commit' => {'symbol' =>
                                                         symbol_data}}})
      end
    end
  end

  context 'without fileRange' do
    let(:file_range) { nil }
    let(:expected_file_range) { nil }

    it_behaves_like 'a GraphQL query', %w(repository commit symbol) do
      let(:expectation_signed_in_existent) do
        match('data' => {'repository' => {'commit' => {'symbol' =>
                                                         symbol_data}}})
      end
    end
  end
end
