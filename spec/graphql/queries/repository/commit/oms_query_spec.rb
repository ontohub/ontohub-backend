# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/commit/oms query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $commitRevision: ID!, $locId: ID!) {
      repository(id: $repositoryId) {
        commit(revision: $commitRevision) {
          oms(locId: $locId) {
            conservativityStatus {
              proved
              required
            }
            consistencyCheckAttempts {
              id
            }
            description
            displayName
            document {
              locId
            }
            fileVersion {
              path
            }
            freeNormalForm {
              locId
            }
            freeNormalFormSignatureMorphism {
              id
            }
            labelHasFree
            labelHasHiding
            locId
            language {
              id
            }
            logic {
              id
            }
            mappings {
              locId
            }
            name
            nameExtension
            nameExtensionIndex
            nameFileRange {
              path
              startLine
              startColumn
              endLine
              endColumn
            }
            normalForm {
              locId
            }
            normalFormSignatureMorphism {
              id
            }
            origin
            sentences {
              locId
            }
            serialization {
              id
            }
            signature {
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
  let!(:oms) do
    create(:oms,
           document: document,
           name_file_range: name_file_range,
           serialization: serialization)
  end
  let!(:consistency_check_attempts) do
    create_list(:consistency_check_attempt, 2, oms: oms).sort_by(&:id)
  end
  let!(:mappings) { create_list(:mapping, 2, source: oms).sort_by(&:loc_id) }
  let!(:sentences) { create_list(:sentence, 2, oms: oms).sort_by(&:loc_id) }

  before do
    oms.normal_form = normal_form
    oms.normal_form_signature_morphism = normal_form_signature_morphism
    oms.free_normal_form = free_normal_form
    oms.free_normal_form_signature_morphism =
      free_normal_form_signature_morphism
    oms.save
  end

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {'repositoryId' => repository.to_param,
     'commitRevision' => commit.id}
  end

  let(:variables_existent) do
    variables_base.merge('locId' => oms.loc_id)
  end
  let(:variables_not_existent) do
    variables_base.merge('locId' => "bad-#{oms.loc_id}")
  end

  let(:expectation_signed_in_existent) do
    match('data' => {'repository' => {'commit' => {'oms' =>
                                                     base_expectation}}})
  end
  let(:expectation_signed_in_not_existent) do
    match('data' => {'repository' => {'commit' => {'oms' => nil}}})
  end
  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end

  let(:expectation_not_signed_in_not_existent) do
    expectation_not_signed_in_existent
  end

  let(:base_expectation) do
    {
      'conservativityStatus' =>
        {'proved' => oms.conservativity_status.proved,
         'required' => oms.conservativity_status.required},
      'consistencyCheckAttempts' =>
        consistency_check_attempts.map { |c| {'id' => c.id} },
      'description' => oms.description,
      'displayName' => oms.display_name,
      'document' => {'locId' => document.loc_id},
      'fileVersion' => {'path' => file_version.path},
      'freeNormalForm' => expected_free_normal_form,
      'freeNormalFormSignatureMorphism' =>
        expected_free_normal_form_signature_morphism,
      'labelHasFree' => oms.label_has_free,
      'labelHasHiding' => oms.label_has_hiding,
      'locId' => oms.loc_id,
      'language' => {'id' => oms.language.to_param},
      'logic' => {'id' => oms.logic.to_param},
      'mappings' => mappings.map { |m| {'locId' => m.loc_id} },
      'name' => oms.name,
      'nameExtension' => oms.name_extension,
      'nameExtensionIndex' => oms.name_extension_index,
      'nameFileRange' => expected_name_file_range,
      'normalForm' => expected_normal_form,
      'normalFormSignatureMorphism' => expected_normal_form_signature_morphism,
      'origin' => oms.origin,
      'sentences' => sentences.map { |s| {'locId' => s.loc_id} },
      'serialization' => expected_serialization,
      'signature' => {'id' => oms.signature.id},
    }
  end

  shared_examples 'case freeNormalForm' do
    context 'with freeNormalForm' do
      let(:free_normal_form) { create(:oms) }
      let(:expected_free_normal_form) { {'locId' => free_normal_form.loc_id} }
      include_examples 'case freeNormalFormSignatureMorphism'
    end

    context 'without freeNormalForm' do
      let(:free_normal_form) { nil }
      let(:expected_free_normal_form) { nil }
      include_examples 'case freeNormalFormSignatureMorphism'
    end
  end

  shared_examples 'case freeNormalFormSignatureMorphism' do
    context 'with freeNormalFormSignatureMorphism' do
      let(:free_normal_form_signature_morphism) { create(:signature_morphism) }
      let(:expected_free_normal_form_signature_morphism) do
        {'id' => free_normal_form_signature_morphism.id}
      end
      include_examples 'case nameFileRange'
    end

    context 'without freeNormalFormSignatureMorphism' do
      let(:free_normal_form_signature_morphism) { nil }
      let(:expected_free_normal_form_signature_morphism) { nil }
      include_examples 'case nameFileRange'
    end
  end

  shared_examples 'case nameFileRange' do
    context 'with nameFileRange' do
      let(:name_file_range) { create(:file_range) }
      let(:expected_name_file_range) do
        {
          'path' => name_file_range.path,
          'startLine' => name_file_range.start_line,
          'startColumn' => name_file_range.start_column,
          'endLine' => name_file_range.end_line,
          'endColumn' => name_file_range.end_column,
        }
      end
      include_examples 'case normalForm'
    end

    context 'without nameFileRange' do
      let(:name_file_range) { nil }
      let(:expected_name_file_range) { nil }
      include_examples 'case normalForm'
    end
  end

  shared_examples 'case normalForm' do
    context 'with normalForm' do
      let(:normal_form) { create(:oms) }
      let(:expected_normal_form) { {'locId' => normal_form.loc_id} }
      include_examples 'case normalFormSignatureMorphism'
    end

    context 'without normalForm' do
      let(:normal_form) { nil }
      let(:expected_normal_form) { nil }
      include_examples 'case normalFormSignatureMorphism'
    end
  end

  shared_examples 'case normalFormSignatureMorphism' do
    context 'with normalFormSignatureMorphism' do
      let(:normal_form_signature_morphism) { create(:signature_morphism) }
      let(:expected_normal_form_signature_morphism) do
        {'id' => normal_form_signature_morphism.id}
      end
      include_examples 'case serialization'
    end

    context 'without normalFormSignatureMorphism' do
      let(:normal_form_signature_morphism) { nil }
      let(:expected_normal_form_signature_morphism) { nil }
      include_examples 'case serialization'
    end
  end

  shared_examples 'case serialization' do
    context 'with serialization' do
      let(:serialization) { create(:serialization) }
      let(:expected_serialization) { {'id' => serialization.to_param} }
      it_behaves_like 'a GraphQL query', %w(repository commit oms)
    end

    context 'without serialization' do
      let(:serialization) { nil }
      let(:expected_serialization) { nil }
      it_behaves_like 'a GraphQL query', %w(repository commit oms)
    end
  end

  include_examples 'case freeNormalForm'
end
