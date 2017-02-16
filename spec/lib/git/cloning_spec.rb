# frozen_string_literal: true

RSpec.shared_examples 'a valid clone' do
  it 'yields an existing git repository' do
    expect(subject.repo_exists?).to be(true)
  end

  it 'yields a bare repository' do
    expect(subject.bare?).to be(true)
  end
end

RSpec.describe(Git::Cloning) do
  before(:all) do
    @path = 'clone.git'
    @commit_count = 3
    @branch_count = 3
  end
  let(:path) { @path }
  let(:commit_count) { @commit_count }
  let(:branch_count) { @branch_count }

  context 'invalid remote' do
    it 'raises an error' do
      expect { Git.clone(@path, "file://#{tempdir}") }.
        to raise_error(Git::Cloning::InvalidRemoteError)
    end
  end

  context 'git clone' do
    context 'on an empty remote', :git_repository do
      git_subject do
        remote = create(:git)
        Git.clone(@path, "file://#{remote.path}")
      end

      it_behaves_like 'a valid clone'

      it 'yields an empty repository' do
        expect(subject).to be_empty
      end
    end

    context 'on a remote with commits and branches', :git_repository do
      git_subject do
        @remote = create(:git, :with_commits, commit_count: @commit_count)
        @remote.create_branch('branch1', 'master~1')
        @remote.create_branch('branch2', 'master~2')
        Git.clone(@path, "file://#{@remote.path}")
      end

      let(:remote) { @remote }

      it_behaves_like 'a valid clone'

      it 'yields a repository with the correct branch names' do
        expect(subject.branch_names).to match_array(%w(master branch1 branch2))
      end

      it 'yields a repository with the correct branches' do
        expect(subject.branches).to match_branches(remote.branches)
      end

      it 'has the correct number of commits' do
        expect(subject.commit_count('master')).to eq(commit_count)
      end
    end
  end

  context 'git svn clone' do
    context 'on an empty remote', :git_repository do
      git_subject do
        remote_paths = create(:svn_repository)
        Git.clone(@path, "file://#{remote_paths.first}")
      end

      it_behaves_like 'a valid clone'

      it 'yields an empty repository' do
        expect(subject).to be_empty
      end
    end

    context 'with an svn-standard layout' do
      context 'on a remote without branches and no additional commits', :git_repository do
        git_subject do
          remote_paths = create(:svn_repository, :with_svn_standard_layout)
          Git.clone(@path, "file://#{remote_paths.first}")
        end

        it_behaves_like 'a valid clone'

        it 'yields a repository with the correct branch names' do
          expect(subject.branch_names).to match_array(%w(master origin/trunk))
        end

        it 'has the correct number of commits' do
          # One commit for setting up the standard layout. Setting up the
          # branches does not count as a commit in terms of git-svn.
          expect(subject.commit_count('master')).to eq(1)
        end
      end

      context 'on a remote with branches, but no additional commits', :git_repository do
        git_subject do
          remote_paths =
            create(:svn_repository, :with_svn_standard_layout,
                   :with_svn_branches, branch_count: @branch_count)
            Git.clone(@path, "file://#{remote_paths.first}")
        end

        it_behaves_like 'a valid clone'

        it 'yields a repository with the correct branch names' do
          subject.branch_names.each do |branch|
            expect(branch).
              to match(%r{master|origin/trunk|origin/my-branch-\d+})
          end
        end

        it 'yields a repository with the correct number of branches' do
          # One additional branch for master and one for origin/trunk
          expect(subject.branch_count).to eq(2 + branch_count)
        end

        it 'has the correct number of commits' do
          # One commit for setting up the standard layout. Setting up the
          # branches does not count as a commit in terms of git-svn.
          expect(subject.commit_count('master')).to eq(1)
        end
      end

      context 'on a remote with commits and branches', :git_repository do
        git_subject do
          @dir = Dir.mktmpdir
          Dir.chdir(@dir) do
            remote_paths =
              create(:svn_repository, :with_svn_standard_layout,
                     :with_svn_branches,
                     :with_svn_commits,
                     branch_count: @branch_count,
                     commit_count: @commit_count)
            Git.clone(@path, "file://#{remote_paths.first}")
          end
        end

        it_behaves_like 'a valid clone'

        it 'yields a repository with the correct branch names' do
          subject.branch_names.each do |branch|
            expect(branch).
              to match(%r{master|origin/trunk|origin/my-branch-\d+})
          end
        end

        it 'yields a repository with the correct number of branches' do
          # One additional branch for master and one for origin/trunk
          expect(subject.branch_count).to eq(2 + branch_count)
        end

        it 'has the correct number of commits' do
          # One commit for setting up the standard layout. Setting up the
          # branches does not count as a commit in terms of git-svn.
          expect(subject.commit_count('master')).to eq(1 + commit_count)
        end
      end
    end

    context 'without an svn-standard layout but with commits', :git_repository do
      git_subject do
        remote_paths =
          create(:svn_repository, :with_svn_commits, commit_count: @commit_count)
        Git.clone(@path, "file://#{remote_paths.first}")
      end

      it_behaves_like 'a valid clone'

      it 'yields a repository with the correct branch names' do
        expect(subject.branch_names).to match_array(%w(master git-svn))
      end

      it 'has the correct number of commits' do
        expect(subject.commit_count('master')).to eq(commit_count)
      end
    end
  end
end
