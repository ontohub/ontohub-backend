# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/commit/document query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $commitRevision: ID!, $locId: ID!) {
      repository(id: $repositoryId) {
        commit(revision: $commitRevision) {
          document(locId: $locId) {
            locId
            documentLinks {
              source {
                locId
              }
              target {
                locId
              }
            }
            fileVersion {
              path
            }
            importedBy {
              locId
            }
            imports {
              locId
            }
            ... on Library {
              oms {
                locId
              }
            }
            ... on NativeDocument {
              oms {
                locId
              }
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
  let(:importers) { create_list(:library, 2).sort_by(&:loc_id) }
  let(:importees) { create_list(:library, 2).sort_by(&:loc_id) }
  before do
    importers.each do |importer|
      create(:document_link, source: importer, target: document)
    end
    importees.each do |importee|
      create(:document_link, source: document, target: importee)
    end
  end

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {'repositoryId' => repository.to_param,
     'commitRevision' => commit.id}
  end

  let(:variables_existent) do
    variables_base.merge('locId' => document.loc_id)
  end
  let(:variables_not_existent) do
    variables_base.merge('locId' => "bad-#{document.loc_id}")
  end

  let(:expectation_signed_in_existent) do
    match('data' => {'repository' => {'commit' => {'document' =>
                                                     expectation_base}}})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'repository' => {'commit' => {'document' => nil}}})
  end
  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end
  let(:expectation_not_signed_in_not_existent) do
    expectation_not_signed_in_existent
  end

  let(:expectation_base) do
    sorted_links = document.document_links.sort_by do |link|
      [link.source_id, link.target_id]
    end
    expected_links = sorted_links.map do |document_link|
      {'source' => {'locId' => document_link.source.loc_id},
       'target' => {'locId' => document_link.target.loc_id}}
    end
    {
      'locId' => document.loc_id,
      'documentLinks' => expected_links,
      'fileVersion' => {'path' => file_version.path},
      'importedBy' => importers.map { |i| {'locId' => i.loc_id} },
      'imports' => importees.map { |i| {'locId' => i.loc_id} },
      'oms' => expected_oms,
    }
  end

  context 'on a Library' do
    let!(:document) { create(:library, file_version: file_version) }
    let!(:oms) { create_list(:oms, 2, document: document).sort_by(&:loc_id) }
    let(:expected_oms) { oms.map { |o| {'locId' => o.loc_id} } }

    it_behaves_like 'a GraphQL query', %w(repository commit document)
  end

  context 'on a NativeDocument' do
    let!(:document) { create(:native_document, file_version: file_version) }
    let!(:oms) { create(:oms, document: document) }
    let(:expected_oms) { {'locId' => oms.loc_id} }

    it_behaves_like 'a GraphQL query', %w(repository commit document)
  end
end
