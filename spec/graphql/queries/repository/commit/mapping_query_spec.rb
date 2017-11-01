# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/commit/mapping query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $commitRevision: ID!, $locId: ID!) {
      repository(id: $repositoryId) {
        commit(revision: $commitRevision) {
          mapping(locId: $locId) {
            conservativityStatus {
              proved
              required
            }
            displayName
            fileVersion {
              path
            }
            freenessParameterLanguage {
              id
            }
            freenessParameterOMS {
              locId
            }
            locId
            name
            origin
            pending
            signatureMorphism {
              id
            }
            source {
              locId
            }
            target {
              locId
            }
            type
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
  let(:source) { create(:oms, document: document) }
  let(:target) { create(:oms) }
  let(:mapping) do
    create(:mapping,
           source: source,
           target: target,
           freeness_parameter_language: freeness_parameter_language,
           freeness_parameter_oms: freeness_parameter_oms)
  end

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {'repositoryId' => repository.to_param,
     'commitRevision' => commit.id}
  end

  let(:variables_existent) do
    variables_base.merge('locId' => mapping.loc_id)
  end
  let(:variables_not_existent) do
    variables_base.merge('locId' => "bad-#{mapping.loc_id}")
  end

  let(:expectation_signed_in_not_existent) do
    match('data' => {'repository' => {'commit' => {'mapping' => nil}}})
  end
  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end

  let(:expectation_not_signed_in_not_existent) do
    expectation_not_signed_in_existent
  end

  let(:mapping_data) do
    {
      'conservativityStatus' =>
        {'proved' => mapping.conservativity_status.proved,
         'required' => mapping.conservativity_status.required},
      'displayName' => mapping.display_name,
      'fileVersion' => {'path' => file_version.path},
      'freenessParameterLanguage' => expected_freeness_parameter_language,
      'freenessParameterOMS' => expected_freeness_parameter_oms,
      'locId' => mapping.loc_id,
      'name' => mapping.name,
      'origin' => mapping.origin,
      'pending' => mapping.pending,
      'signatureMorphism' => {'id' => mapping.signature_morphism.id},
      'source' => {'locId' => source.loc_id},
      'target' => {'locId' => target.loc_id},
      'type' => mapping.type,
    }
  end

  context 'with freenessParameterLanguage and freenessParameterOMS' do
    let(:freeness_parameter_language) { create(:language) }
    let(:freeness_parameter_oms) { create(:oms) }
    let(:expected_freeness_parameter_language) do
      {'id' => freeness_parameter_language.to_param}
    end
    let(:expected_freeness_parameter_oms) do
      {'locId' => freeness_parameter_oms.loc_id}
    end

    it_behaves_like 'a GraphQL query', %w(repository commit mapping) do
      let(:expectation_signed_in_existent) do
        match('data' => {'repository' => {'commit' => {'mapping' =>
                                                         mapping_data}}})
      end
    end
  end

  context 'without freenessParameterLanguage and freenessParameterOMS' do
    let(:freeness_parameter_language) { nil }
    let(:freeness_parameter_oms) { nil }
    let(:expected_freeness_parameter_language) { nil }
    let(:expected_freeness_parameter_oms) { nil }

    it_behaves_like 'a GraphQL query', %w(repository commit mapping) do
      let(:expectation_signed_in_existent) do
        match('data' => {'repository' => {'commit' => {'mapping' =>
                                                         mapping_data}}})
      end
    end
  end
end
