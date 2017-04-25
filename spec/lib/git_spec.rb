# frozen_string_literal: true

RSpec.describe(Git) do
  subject { create(:git) }
  let(:branch) { 'master' }
  let(:invalid_sha) { '0' * 40 }

  context 'create' do
    it 'fails if the path already exists' do
      path = tempdir.join('repo')
      path.mkpath
      expect { Git.create(path) }.to raise_error(Git::Error, /already exists/)
    end

    let!(:git) { Git.create('my_repo') }

    it 'is a Git' do
      expect(git).to be_a(Git)
    end

    it 'creates an existing git repository' do
      expect(git.repo_exists?).to be(true)
    end

    it 'creates a bare repository' do
      expect(git.bare?).to be(true)
    end

    it 'creates an empty repository' do
      expect(git.empty?).to be(true)
    end

    it 'creates a repository with no branches' do
      expect(git.branch_count).to eq(0)
    end

    it 'creates a directory at its path' do
      expect(File.directory?(git.path)).to be(true)
    end
  end

  context 'destroy' do
    before do
      # create the subject
      subject
      # and destroy it
      Git.destroy(subject.path)
    end

    it 'removes the directory of the git repository' do
      expect(File.exist?(subject.path)).to be(false)
    end
  end

  context 'path' do
    it 'is a Pathname' do
      expect(subject.path).to be_a(Pathname)
    end

    it 'is an absolute path' do
      expect(subject.path.absolute?).to be(true)
    end
  end

  context 'repo_exists?' do
    context 'when the repository exists' do
      let!(:git) { Git.create('my_repo') }

      it 'is true' do
        expect(git.repo_exists?).to be(true)
      end
    end

    context 'when the repository does not exist' do
      let!(:git) { Git.new('my_repo') }

      it 'is true' do
        expect(git.repo_exists?).to be(false)
      end
    end
  end

  context 'blob' do
    let(:filepath) { generate(:filepath) }
    let(:content) { 'some content' }
    let!(:sha) do
      subject.create_file(create(:git_commit_info,
                                 filepath: filepath,
                                 content: content,
                                 branch: branch))
    end

    it 'returns the blob by the branch' do
      expect(subject.blob(branch, filepath)).not_to be(nil)
    end

    it 'returns the same blob by the sha/branch' do
      expect(subject.blob(sha, filepath)).
        to match_blob(subject.blob(branch, filepath))
    end

    it 'returns nil if the path does not exist' do
      expect(subject.blob(sha, "#{filepath}.bad")).to be(nil)
    end

    it 'raises an error if the reference does not exist' do
      expect { subject.blob(invalid_sha, filepath) }.
        to raise_error(Rugged::ReferenceError)
    end

    it 'contains the content' do
      expect(subject.blob(sha, filepath).data).to eq(content)
    end

    it "contains the content's size" do
      expect(subject.blob(sha, filepath).size).to eq(content.size)
    end

    it 'contains the filepath' do
      expect(subject.blob(sha, filepath).path).to eq(filepath)
    end

    it 'contains the filename' do
      expect(subject.blob(sha, filepath).name).to eq(File.basename(filepath))
    end
  end

  context 'tree' do
    let(:filepath1) { generate(:filepath) }
    let(:filepath2) { generate(:filepath) }
    let(:content) { 'some content' }
    let!(:sha1) do
      subject.create_file(create(:git_commit_info,
                                 filepath: filepath1,
                                 content: content,
                                 branch: branch))
    end
    let!(:sha2) do
      subject.create_file(create(:git_commit_info,
                                 filepath: filepath2,
                                 content: content,
                                 branch: branch))
    end

    it 'returns the tree by the branch and nil' do
      expect(subject.tree(branch, nil)).not_to be(nil)
    end

    it 'returns the same tree by the branch and nil/root' do
      expect(subject.tree(branch, nil)).to match_tree(subject.tree(branch, '/'))
    end

    it 'returns the same tree by the sha/branch' do
      expect(subject.tree(sha2, nil)).to match_tree(subject.tree(branch, nil))
    end

    it 'returns an empty Array if no tree exists at the path' do
      expect(subject.tree(branch, filepath1)).to be_empty
    end

    it 'raises an error if the reference does not exist' do
      expect { subject.tree(invalid_sha, nil) }.
        to raise_error(Rugged::ReferenceError)
    end

    it 'lists the correct entries in the root @ HEAD' do
      expect(subject.tree(branch, nil).map(&:path)).
        to match_array([filepath1, filepath2].map { |f| File.dirname(f) })
    end

    it "lists the correct entries's paths in one directory @ HEAD" do
      expect(subject.tree(branch, File.dirname(filepath1)).map(&:path)).
        to match_array([filepath1])
    end

    it "lists the correct entries's names in one directory @ HEAD" do
      expect(subject.tree(branch, File.dirname(filepath1)).map(&:name)).
        to match_array([File.basename(filepath1)])
    end

    it 'lists the correct entries in the root @ HEAD~1' do
      expect(subject.tree(sha1, nil).map(&:path)).
        to match_array([File.dirname(filepath1)])
    end

    it 'lists the correct entries in one directory @ HEAD~1' do
      expect(subject.tree(sha1, File.dirname(filepath1)).map(&:path)).
        to match_array([filepath1])
    end
  end

  context 'commit' do
    let(:filepath) { generate(:filepath) }
    let(:content) { 'some content' }
    let(:author) { generate(:git_user) }
    let(:committer) { generate(:git_user) }
    let(:message) { generate(:commit_message) }
    let(:commit_info) do
      commit_info = create(:git_commit_info,
                           filepath: filepath,
                           content: content,
                           branch: branch)
      commit_info[:author] = author
      commit_info[:committer] = committer
      commit_info[:commit][:message] = message
      commit_info
    end
    let!(:sha) { subject.create_file(commit_info) }

    it 'finds a commit by branch' do
      expect(subject.commit(branch)).to be_a(Gitlab::Git::Commit)
    end

    it 'finds the same commit by sha/branch' do
      expect(subject.commit(sha)).to match_commit(subject.commit(branch))
    end

    it 'returns nil if the reference does not exist' do
      expect(subject.commit(invalid_sha)).to be(nil)
    end

    it 'contains author name' do
      expect(subject.commit(branch).author_name).to eq(author[:name])
    end

    it 'contains author email' do
      expect(subject.commit(branch).author_email).to eq(author[:email])
    end

    it 'contains authored date' do
      expect(subject.commit(branch).authored_date).
        to match_git_date(author[:time])
    end

    it 'contains committer name' do
      expect(subject.commit(branch).committer_name).to eq(committer[:name])
    end

    it 'contains committer email' do
      expect(subject.commit(branch).committer_email).to eq(committer[:email])
    end

    it 'contains committed date' do
      expect(subject.commit(branch).committed_date).
        to match_git_date(committer[:time])
    end

    it 'contains the id' do
      expect(subject.commit(branch).id).to eq(sha)
    end

    it 'contains the message' do
      expect(subject.commit(branch).message).to eq(message)
    end
  end

  context 'path_exists?' do
    let(:filepath) { generate(:filepath) }
    let!(:sha) do
      subject.create_file(create(:git_commit_info,
                                 filepath: filepath,
                                 branch: branch))
    end

    it 'is true if the path points to a blob' do
      expect(subject.path_exists?(branch, filepath)).to be(true)
    end

    it 'is true if the path points to a blob @ sha' do
      expect(subject.path_exists?(sha, filepath)).to be(true)
    end

    it 'is true if the path points to a tree' do
      expect(subject.path_exists?(branch, File.dirname(filepath))).to be(true)
    end

    it 'is false if the path points to nothing' do
      expect(subject.path_exists?(branch, "#{filepath}.bad")).to be(false)
    end
  end

  context 'branch_sha' do
    let!(:sha) do
      subject.create_file(create(:git_commit_info, branch: branch))
    end

    it 'is the correct sha if the branch exists' do
      expect(subject.branch_sha(branch)).to eq(sha)
    end

    it 'is nil if the branch does not exist' do
      expect(subject.branch_sha("#{branch}-bad")).to be(nil)
    end
  end

  context 'default_branch' do
    context 'without branches' do
      it 'is nil' do
        expect(subject.default_branch).to be(nil)
      end
    end

    context 'with only one branch' do
      let(:default_branch) { 'main' }
      before do
        commit_info = create(:git_commit_info)
        commit_info[:commit][:branch] = default_branch
        subject.create_file(commit_info)
      end

      it 'is that branch' do
        expect(subject.default_branch).to eq(default_branch)
      end
    end

    context 'with many branches' do
      let(:default_branch) { 'main' }
      let(:other_branch) { 'other' }

      before do
        commit_info = create(:git_commit_info)
        commit_info[:commit][:branch] = default_branch
        subject.create_file(commit_info)

        subject.create_branch(other_branch, default_branch)

        commit_info = create(:git_commit_info)
        commit_info[:commit][:branch] = other_branch
        subject.create_file(commit_info)
      end

      it 'is the first created branch' do
        expect(subject.default_branch).to eq(default_branch)
      end

      context 'setting the default branch' do
        before do
          subject.default_branch = other_branch
        end

        it 'sets the branch to the other one' do
          expect(subject.default_branch).to eq(other_branch)
        end
      end
    end

    context 'with many branches including master' do
      let(:default_branch) { 'main' }
      let(:other_branch) { 'other' }
      before do
        commit_info = create(:git_commit_info)
        commit_info[:commit][:branch] = default_branch
        subject.create_file(commit_info)

        subject.create_branch(other_branch, default_branch)

        commit_info = create(:git_commit_info)
        commit_info[:commit][:branch] = other_branch
        subject.create_file(commit_info)

        master_branch = 'master'
        subject.create_branch(master_branch, default_branch)

        commit_info = create(:git_commit_info)
        commit_info[:commit][:branch] = master_branch
        subject.create_file(commit_info)
      end

      it 'is the master' do
        expect(subject.default_branch).to eq('master')
      end

      context 'setting the default branch' do
        before do
          subject.default_branch = other_branch
        end

        it 'sets the branch to the other one' do
          expect(subject.default_branch).to eq(other_branch)
        end
      end
    end
  end

  context 'create_branch' do
    let!(:sha1) do
      subject.create_file(create(:git_commit_info, branch: branch))
    end

    let!(:sha2) do
      subject.create_file(create(:git_commit_info, branch: branch))
    end

    let(:new_branch) { 'new_branch' }

    RSpec.shared_examples 'a valid branch' do
      it 'points to the correct sha' do
        expect(subject.branch_sha(new_branch)).to eq(sha)
      end
    end

    context 'by sha' do
      before { subject.create_branch(new_branch, sha1) }
      it_behaves_like 'a valid branch' do
        let(:sha) { sha1 }
      end
    end

    context 'by branch' do
      before { subject.create_branch(new_branch, branch) }
      it_behaves_like 'a valid branch' do
        let(:sha) { subject.branch_sha(branch) }
      end
    end

    context 'by branch-backtrace' do
      before { subject.create_branch(new_branch, "#{branch}~1") }
      it_behaves_like 'a valid branch' do
        let(:sha) { sha1 }
      end
    end
  end

  context 'ls_files' do
    let(:filepaths) { (1..5).map { generate(:filepath) } }
    before do
      filepaths.each do |filepath|
        subject.create_file(create(:git_commit_info, filepath: filepath))
      end
    end

    it 'returns the filepaths' do
      expect(subject.ls_files(branch)).to match_array(filepaths)
    end
  end
end
