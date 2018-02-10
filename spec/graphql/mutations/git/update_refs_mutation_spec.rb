# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'updateRefs mutation' do
  let!(:public_key) { create(:public_key) }
  let!(:pusher) { public_key.user }
  let!(:repository) { create(:repository_compound, :not_empty, owner: pusher) }
  let!(:git) { repository.git }
  let!(:old_filename) { generate(:filepath) }
  let!(:new_filename) { generate(:filepath) }
  let!(:branch1) do
    create(:branch, repository: repository, revision: git.default_branch).name
  end
  let!(:branch2) do
    create(:branch, repository: repository, revision: git.default_branch).name
  end
  let!(:branch1_creation_commit) do
    git.commit(create(:additional_commit, repository: repository,
                                          branch: branch1,
                                          files: [{action: 'create',
                                                   path: old_filename,
                                                   content: generate(:content),
                                                   encoding: 'plain'}]))
  end
  let!(:branch1_renaming_commit) do
    git.commit(create(:additional_commit, repository: repository,
                                          branch: branch1,
                                          files: [{action: 'rename_and_update',
                                                   new_path: new_filename,
                                                   path: old_filename,
                                                   content: generate(:content),
                                                   encoding: 'plain'}]))
  end
  let!(:branch1_deletion_commit) do
    git.commit(create(:additional_commit, repository: repository,
                                          branch: branch1,
                                          files: [{action: 'remove',
                                                   path: new_filename}]))
  end
  let!(:branch2_creation_commit) do
    git.commit(create(:additional_commit, repository: repository,
                                          branch: branch2,
                                          files: [{action: 'create',
                                                   path: old_filename,
                                                   content: generate(:content),
                                                   encoding: 'plain'}]))
  end
  let(:updated_refs) do
    [{'ref' => branch1,
      'before' => git.commit(git.default_branch).id,
      'after' => git.commit(branch1).id},
     {'ref' => branch2,
      'before' => git.commit(git.default_branch).id,
      'after' => git.commit(branch2).id}]
  end

  # Clean the state. We want to test if the described mutation creates each
  # FileVersion. The :additional_commit and :repository_compound factories have
  # created FileVersions along the way.
  before do
    FileVersion.each(&:destroy)
  end

  let(:context) { {current_user: current_user} }
  let(:variables) do
    {'keyId' => public_key.id,
     'repositoryId' => repository.to_param,
     'updatedRefs' => updated_refs}
  end

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation ($keyId: Int!, $repositoryId: ID!, $updatedRefs: [UpdatedRef!]!) {
      updateRefs(keyId: $keyId, repositoryId: $repositoryId, updatedRefs: $updatedRefs)
    }
    QUERY
  end

  subject { result }

  context 'when not authorized to perform this action' do
    shared_examples 'unauthorized' do
      it 'returns the correct result' do
        expect(subject['data']).to be(nil)
      end
    end

    context 'as a user' do
      let(:current_user) { create(:user) }
      include_examples 'unauthorized'
    end

    context 'as a HetsApiKey' do
      let(:current_user) { create(:hets_api_key) }
      include_examples 'unauthorized'
    end

    context 'not signed in' do
      let(:current_user) { nil }
      include_examples 'unauthorized'
    end
  end

  context 'when authorized to perform this action' do
    let(:current_user) { create(:git_shell_api_key) }

    context 'when no error occurs' do
      it 'returns true' do
        expect(subject['data']['updateRefs']).to be(true)
      end

      shared_examples 'sending a ProcecessCommitJob' do
        it 'is enqueued' do
          expect { subject }.
            to have_enqueued_job(ProcessCommitJob).
            with(repository.pk, commit_sha)
        end
      end

      context 'ProcessCommitJob for' do
        context 'the file-creating commit of branch1' do
          include_examples 'sending a ProcecessCommitJob' do
            let(:commit_sha) { branch1_creation_commit.id }
          end
        end

        context 'the file-renaming commit of branch1' do
          include_examples 'sending a ProcecessCommitJob' do
            let(:commit_sha) { branch1_renaming_commit.id }
          end
        end

        context 'the file-deleting commit of branch1' do
          include_examples 'sending a ProcecessCommitJob' do
            let(:commit_sha) { branch1_deletion_commit.id }
          end
        end

        context 'the file-creating commit of branch2' do
          include_examples 'sending a ProcecessCommitJob' do
            let(:commit_sha) { branch2_creation_commit.id }
          end
        end
      end

      shared_examples 'creating a FileVersion' do
        before { subject }

        it 'creates a FileVersion' do
          expect(FileVersion.first(repository_id: repository.pk,
                                   commit_sha: commit_sha,
                                   path: path)).not_to be(nil)
        end
      end

      context 'FileVersions' do
        context 'on branch1_creation_commit' do
          include_examples 'creating a FileVersion' do
            let(:commit_sha) { branch1_creation_commit.id }
            let(:path) { old_filename }
          end
        end

        context 'on branch1_renaming_commit' do
          include_examples 'creating a FileVersion' do
            let(:commit_sha) { branch1_renaming_commit.id }
            let(:path) { new_filename }
          end
        end

        it 'does not create a FileVersion for the deleted file' do
          subject
          commit_sha = branch1_deletion_commit.id
          path = new_filename
          expect(FileVersion.first(repository_id: repository.pk,
                                   commit_sha: commit_sha,
                                   path: path)).to be(nil)
        end

        context 'on branch2_creation_commit' do
          include_examples 'creating a FileVersion' do
            let(:commit_sha) { branch2_creation_commit.id }
            let(:path) { old_filename }
          end
        end
      end
    end

    context 'when an error occurs' do
      before do
        allow_any_instance_of(RefsUpdater).
          to receive(:call).
          and_raise(StandardError)
        allow(Rails.logger).to receive(:error)
      end

      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end

      it 'returns false' do
        expect(subject['data']['updateRefs']).to be(false)
      end

      it 'calls the logger' do
        subject
        expect(Rails.logger).
          to have_received(:error).
          with(match(/arguments:.*\s*backtrace:/))
      end
    end
  end
end
