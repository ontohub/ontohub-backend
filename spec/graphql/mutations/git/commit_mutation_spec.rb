# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'commit mutation' do
  let!(:user) { create(:user) }
  let!(:repository) { create(:repository_compound, owner: user) }

  # Setup the repository
  let(:num_setup_files) { 6 }
  let!(:file_range) { (0..num_setup_files - 1) }
  let!(:old_files) { file_range.map { generate(:filepath) } }
  let!(:new_files) { file_range.map { generate(:filepath) } }
  let!(:old_contents) { file_range.map { generate(:content) } }
  let!(:new_contents) { file_range.map { generate(:content) } }
  let!(:setup_commit) do
    info = create(:git_commit_info, branch: branch)
    info.delete(:file)
    info[:files] = []
    file_range.each do |i|
      info[:files] << {path: old_files[i],
                       content: old_contents[i],
                       action: :create}
    end
    commit_sha = repository.git.commit_multichange(info)
    old_files.each do |old_file|
      FileVersion.create(repository_id: repository.id,
                         commit_sha: commit_sha,
                         path: old_file)
    end
    commit_sha
  end

  let(:branch) { 'master' }
  let(:branch_argument) { branch }
  let(:lastKnownHeadId) { setup_commit }
  let(:lastKnownHeadId_argument) { lastKnownHeadId }
  let(:message) { generate(:commit_message) }
  let(:message_argument) { message }
  let(:files) do
    [{'path' => new_files[0],
      'content' => new_contents[0],
      'encoding' => 'plain',
      'action' => 'create'},

     {'new_path' => new_files[1],
      'path' => old_files[1],
      'action' => 'rename'},

     {'path' => old_files[2],
      'content' => new_contents[2],
      'encoding' => 'plain',
      'action' => 'update'},

     {'new_path' => new_files[3],
      'content' => new_contents[3],
      'encoding' => 'plain',
      'path' => old_files[3],
      'action' => 'update'},

     {'path' => old_files[4],
      'action' => 'remove'},

     {'path' => new_files[5],
      'action' => 'mkdir'}]
  end
  let(:files_argument) { files }

  let(:context) { {current_user: user} }
  let(:variables) do
    {'repositoryId' => repository.to_param,
     'newCommit' => {'branch' => branch_argument,
                     'lastKnownHeadId' => lastKnownHeadId_argument,
                     'message' => message_argument,
                     'files' => files_argument}}
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
    mutation ($repositoryId: ID!, $newCommit: NewCommit!) {
      commit(repositoryId: $repositoryId, newCommit: $newCommit) {
        __typename
        id
        parentIds
        message
        referenceNames
        references {
          __typename
          name
          target {
            id
          }
        }
        author {
          name
        }
        authoredAt
        committer {
          name
        }
        committedAt
      }
    }
    QUERY
  end

  subject { result }

  RSpec.shared_examples 'committing was successful via GraphQL' do
    it 'returns the commit fields AND creates the commit as the new HEAD' do
      subject
      branch_id = repository.git.commit(branch).id
      expect(subject['data']['commit']).to include(
        'id' => branch_id,
        'parentIds' => [setup_commit],
        'message' => message,
        'referenceNames' => [branch],
        'references' => include(include('__typename' => 'Branch',
                                        'name' => branch,
                                        'target' =>
                                          include('id' => branch_id))),
        'author' => {'name' => user.to_param},
        'authoredAt' => be_a(Float),
        'committer' => {'name' => user.to_param},
        'committedAt' => be_a(Float)
      )
    end

    context 'git checks' do
      let(:git) { repository.git }

      before { subject }

      it 'performs the rename action: the new filename exists' do
        expect(git.blob(branch, new_files[1]).data).to eq(old_contents[1])
      end

      it 'performs the rename action: the old filename does not exist' do
        expect(git.blob(branch, old_files[1])).to be_nil
      end

      it 'performs the non-renaming update action: new content correct' do
        expect(git.blob(branch, old_files[2]).data).to eq(new_contents[2])
      end

      it 'performs the non-renaming update action: old content not there' do
        expect(git.blob(branch, old_files[2]).data).not_to eq(old_contents[2])
      end

      it 'performs the renaming update action: new filename and content' do
        expect(git.blob(branch, new_files[3]).data).to eq(new_contents[3])
      end

      it 'performs the renaming update action: the old content is gone' do
        expect(git.blob(branch, new_files[3]).data).not_to eq(old_contents[3])
      end

      it 'performs the renaming update action: '\
        'the old filename does not exist' do
        expect(git.blob(branch, old_files[3])).to be_nil
      end

      it 'performs the removing action' do
        expect(git.blob(branch, old_files[4])).to be_nil
      end

      it 'performs the mkdir action: no blob exists at path' do
        expect(git.blob(branch, new_files[5])).to be_nil
      end

      it 'performs the mkdir action: .gitkeep exists under path' do
        expect(git.tree(branch, new_files[5]).first.path).
          to end_with('/.gitkeep')
      end

      it 'only adds one log entry' do
        expect(git.log(ref: "#{branch}~").first.id).to eq(setup_commit)
      end
    end
  end

  context 'Successful creation' do
    context 'with a correct lastKnownHeadId' do
      it_behaves_like 'committing was successful via GraphQL'
    end

    context 'without a lastKnownHeadId' do
      let(:variables) do
        {'repositoryId' => repository.to_param,
         'newCommit' => {'branch' => branch_argument,
                         'message' => message_argument,
                         'files' => files_argument}}
      end
      it_behaves_like 'committing was successful via GraphQL'
    end
  end

  context 'Unsuccessful' do
    context 'because of an inexistant branch' do
      let(:branch_argument) { 'inexistant' }

      it 'returns no data' do
        expect(subject['data']['commit']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => include('branch does not exist')))
      end
    end

    context 'because of a bad lastKnownHeadId' do
      let(:lastKnownHeadId_argument) { '0' * 40 }

      it 'returns no data' do
        expect(subject['data']['commit']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => include('changed in the meantime.')))
      end
    end

    context 'because of an empty message' do
      let(:message_argument) { '' }

      it 'returns no data' do
        expect(subject['data']['commit']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => match(/message.*must be present/)))
      end
    end

    context 'because of a bad files array' do
      let(:files_argument) do
        files[0]['path'] = old_files[0]
        files
      end

      it 'returns no data' do
        expect(subject['data']['commit']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => include('path already exists')))
      end
    end
    context 'because the user is not signed in' do
      let(:context) { {} }

      it 'returns no data' do
        expect(subject['data']['commit']).to be(nil)
      end

      it 'returns an error' do
        expect(subject['errors']).
          to include(include('message' => "You're not authorized to do this"))
      end
    end
  end
end
