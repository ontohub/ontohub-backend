# frozen_string_literal: true

RSpec.describe(FileVersionParentsCreator) do
  let(:repository) { create(:repository_compound) }
  let(:files) { (1..4).map { generate(:filepath) } }
  let(:commit_file_directly) do
    lambda do |files_to_commit|
      commit_files =
        files_to_commit.map do |file|
          {path: file,
           content: '',
           action: :create}
        end
      commit_user = GitHelper.git_user(repository.owner, Time.now)
      commit_info = {files: commit_files,
                     author: commit_user,
                     committer: commit_user,
                     commit: {message: generate(:commit_message),
                              branch: repository.git.default_branch}}
      sha = repository.git.commit_multichange(commit_info, nil)
      files_to_commit.each do |file|
        FileVersion.create(repository: repository, commit_sha: sha, path: file)
      end
      sha
    end
  end

  context 'first commit' do
    let!(:commit_sha1) { commit_file_directly.call(files) }

    before do
      FileVersionParentsCreator.new(repository.id, commit_sha1).call
    end

    it 'creates the "reflexive" FileVersionParents' do
      files.each do |file|
        file_version = FileVersion.find(repository_id: repository.id,
                                        commit_sha: commit_sha1,
                                        path: file)
        expect(FileVersionParent.
                 find(queried_sha: commit_sha1,
                      last_changed_file_version: file_version)).
          not_to be(nil)
      end
    end

    context 'second commit not changing previous files' do
      let!(:commit_sha2) { commit_file_directly.call([generate(:filepath)]) }

      before do
        FileVersionParentsCreator.new(repository.id, commit_sha2).call
      end

      it 'creates the backwards FileVersionParents' do
        files.each do |file|
          file_version = FileVersion.find(repository_id: repository.id,
                                          commit_sha: commit_sha1,
                                          path: file)
          expect(FileVersionParent.
                   find(queried_sha: commit_sha2,
                        last_changed_file_version: file_version)).
            not_to be(nil)
        end
      end
    end
  end
end
