# frozen_string_literal: true

RSpec.describe(Git::Pulling) do
  let(:path) { 'clone.git' }
  let(:commit_count) { 3 }

  context 'from a remote git repository' do
    let(:remote) { create(:git) }
    let(:commit_count) { 3 }

    subject { Git.clone(path, "file://#{remote.path}") }

    before do
      # clone the repository
      subject

      # create commits
      commit_count.times { remote.commit_file(create(:git_commit_info)) }

      # create branches
      remote.create_branch('branch1', 'master~1')
      remote.create_branch('branch2', 'master~2')

      # pull
      subject.pull
    end

    it 'yields a repository with the correct branch names' do
      expect(subject.branch_names).to match_array(%w(master branch1 branch2))
    end

    it 'yields a repository with the correct branches' do
      %i(name target dereferenced_target).each do |attribute|
        expect(subject.branches.map(&attribute)).
          to match_array(remote.branches.map(&attribute))
      end
    end

    it 'has the correct number of commits' do
      expect(subject.commit_count('master')).to eq(commit_count)
    end
  end

  context 'from a remote svn repository' do
    context 'with an svn standard layout' do
      let(:branch_count) { 3 }
      let(:remote_paths) do
        create(:svn_repository, :with_svn_standard_layout)
      end
      let(:svn_work_path) { remote_paths.last }
      subject { Git.clone(path, "file://#{remote_paths.first}") }

      before do
        # clone the repository
        subject

        # create branches
        branch_count.times do
          branch = generate(:svn_branch_name)
          full_filepath = File.join(svn_work_path, 'branches', branch)
          FileUtils.mkdir_p(full_filepath)
          exec_silently("svn add #{full_filepath}", svn_work_path)
        end
        exec_silently("svn commit -m 'Add branches.'", svn_work_path)

        # create commits
        commit_count.times do
          full_filepath = File.join(svn_work_path, 'trunk', generate(:filepath))
          FileUtils.mkdir_p(File.dirname(full_filepath))
          File.write(full_filepath, "#{Faker::Lorem.sentence}\n")
          exec_silently("svn add '#{File.dirname(full_filepath)}'",
                        svn_work_path)
          exec_silently("svn commit -m '#{generate(:commit_message)}'",
                        svn_work_path)
        end

        # pull
        subject.pull
      end

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

    context 'without an svn standard layout' do
      let(:remote_paths) { create(:svn_repository) }
      let(:svn_work_path) { remote_paths.last }
      subject { Git.clone(path, "file://#{remote_paths.first}") }

      before do
        # clone the repository
        subject

        # create commits
        commit_count.times do
          full_filepath = File.join(svn_work_path, generate(:filepath))
          FileUtils.mkdir_p(File.dirname(full_filepath))
          File.write(full_filepath, "#{Faker::Lorem.sentence}\n")
          exec_silently("svn add '#{File.dirname(full_filepath)}'",
                        svn_work_path)
          exec_silently("svn commit -m '#{generate(:commit_message)}'",
                        svn_work_path)
        end

        # pull
        subject.pull
      end

      it 'yields a repository with the correct branch names' do
        expect(subject.branch_names).to match_array(%w(master git-svn))
      end

      it 'has the correct number of commits' do
        expect(subject.commit_count('master')).to eq(commit_count)
      end
    end
  end
end
