# frozen_string_literal: true

RSpec.describe(Git::Committing) do
  context 'without errors' do
    subject { create(:git) }

    %w(master some_feature).each do |branch|
      it "has not yet created the #{branch} branch" do
        expect(subject.branch_exists?('master')).to be(false)
      end

      context "working on branch '#{branch}'" do
        if branch == 'master'
          let!(:additional_commit) { nil }
        else
          let!(:additional_commit) do
            subject.commit_file(create(:git_commit_info,
                                       filepath: 'first_file'))
          end
          before { subject.create_branch(branch, 'master') }
        end
        let(:prior_commits) { additional_commit.nil? ? 0 : 1 }

        context 'adding a file' do
          let(:filepath) { generate(:filepath) }
          let!(:sha) do
            subject.commit_file(create(:git_commit_info,
                                       filepath: filepath,
                                       branch: branch))
          end

          it 'creates a branch' do
            expect(subject.branch_exists?(branch)).to be(true)
          end

          it 'creates a new commit on the branch' do
            expect(subject.find_commits(ref: branch).size).
              to be(1 + prior_commits)
          end

          it 'sets the HEAD of the branch to the latest commit' do
            expect(subject.branch_sha(branch)).to eq(sha)
          end

          it 'creates the correct number of commits on that file' do
            expect(subject.log(ref: branch, path: filepath).map(&:oid)).
              to eq([sha])
          end

          it 'creates the file' do
            expect(subject.blob(branch, filepath)).not_to be_nil
          end
        end

        context 'updating a file' do
          let(:filepath) { generate(:filepath) }
          let!(:sha1) do
            subject.commit_file(create(:git_commit_info,
                                       filepath: filepath,
                                       branch: branch))
          end
          let!(:content1) { subject.blob(branch, filepath).data }
          let!(:sha2) do
            subject.commit_file(create(:git_commit_info,
                                       filepath: filepath,
                                       branch: branch),
                                sha1)
          end
          let!(:content2) { subject.blob(branch, filepath).data }

          it 'sets the HEAD of the branch to the latest commit' do
            expect(subject.branch_sha(branch)).to eq(sha2)
          end

          it 'creates the correct number of commits on that file' do
            expect(subject.log(ref: branch, path: filepath).map(&:oid)).
              to eq([sha2, sha1])
          end

          it 'changes the content' do
            expect(content2).not_to eq(content1)
          end
        end

        context 'renaming a file' do
          let(:filepath1) { generate(:filepath) }
          let(:filepath2) { generate(:filepath) }
          let!(:sha1) do
            subject.commit_file(create(:git_commit_info,
                                       filepath: filepath1,
                                       branch: branch))
          end
          let!(:content1) { subject.blob(branch, filepath1).data }
          let!(:sha2) do
            commit_info = create(:git_commit_info,
                                 filepath: filepath2,
                                 branch: branch)
            commit_info[:file].merge!(previous_path: filepath1,
                                      content: content1)
            subject.rename_file(commit_info, sha1)
          end
          let!(:content2) { subject.blob(branch, filepath2).data }

          it 'sets the HEAD of the branch to the latest commit' do
            expect(subject.branch_sha(branch)).to eq(sha2)
          end

          it 'creates the correct number of commits on that file' do
            expect(subject.log(ref: branch, path: filepath2).map(&:oid)).
              to eq([sha2])
          end

          it 'does not change the content' do
            expect(content2).to eq(content1)
          end
        end

        context 'deleting a file' do
          let(:filepath) { generate(:filepath) }
          let!(:sha1) do
            subject.commit_file(create(:git_commit_info,
                                       filepath: filepath,
                                       branch: branch))
          end
          let!(:sha2) do
            commit_info = create(:git_commit_info,
                                 filepath: filepath,
                                 branch: branch)
            commit_info[:file].delete(:content)
            subject.remove_file(commit_info, sha1)
          end

          it 'sets the HEAD of the branch to the latest commit' do
            expect(subject.branch_sha(branch)).to eq(sha2)
          end

          it 'creates the correct number of commits on that file' do
            expect(subject.log(ref: branch, path: filepath).map(&:oid)).
              to eq([sha2, sha1])
          end

          it 'removes the file' do
            expect(subject.blob(branch, filepath)).to be_nil
          end
        end

        context 'creating a directory' do
          let!(:path) { 'dir/with/subdir' }
          let!(:sha) do
            subject.mkdir(path, create(:git_commit_info, branch: branch))
          end

          it 'creates a tree at the path' do
            expect(subject.tree(branch, path)).not_to be_nil
          end

          it 'creates a .gitkeep file in the directory' do
            expect(subject.blob(branch, File.join(path, '.gitkeep'))).
              not_to be_nil
          end
        end
      end
    end
  end

  context 'when the branch changed' do
    subject { create(:git) }
    let(:branch) { 'master' }
    let(:invalid_sha) { '0' * 40 }

    context 'adding a file' do
      before do
        subject.commit_file(create(:git_commit_info,
                                   filepath: 'first_file',
                                   branch: branch))
      end

      let(:filepath) { generate(:filepath) }

      it 'raises an error' do
        expect do
          subject.commit_file(create(:git_commit_info,
                                     filepath: filepath,
                                     branch: branch),
                              invalid_sha)
        end.to raise_error(Git::HeadChangedError)
      end
    end

    context 'updating a file' do
      let(:filepath) { generate(:filepath) }
      let!(:sha) do
        subject.commit_file(create(:git_commit_info,
                                   filepath: filepath,
                                   branch: branch))
      end

      it 'raises an error' do
        expect do
          subject.commit_file(create(:git_commit_info,
                                     filepath: filepath,
                                     branch: branch),
                              invalid_sha)
        end.to raise_error(Git::HeadChangedError)
      end
    end

    context 'renaming a file' do
      let(:filepath1) { generate(:filepath) }
      let(:filepath2) { generate(:filepath) }
      let!(:sha) do
        subject.commit_file(create(:git_commit_info,
                                   filepath: filepath1,
                                   branch: branch))
      end
      let!(:content1) { subject.blob(branch, filepath1).data }

      it 'raises an error' do
        expect do
          commit_info = create(:git_commit_info,
                               filepath: filepath2,
                               branch: branch)
          commit_info[:file].merge!(previous_path: filepath1,
                                    content: content1)
          subject.rename_file(commit_info, invalid_sha)
        end.to raise_error(Git::HeadChangedError)
      end
    end

    context 'deleting a file' do
      let(:filepath) { generate(:filepath) }
      let!(:sha) do
        subject.commit_file(create(:git_commit_info,
                                   filepath: filepath,
                                   branch: branch))
      end
      it 'raises an error' do
        expect do
          commit_info = create(:git_commit_info,
                               filepath: filepath,
                               branch: branch)
          commit_info[:file].delete(:content)
          subject.remove_file(commit_info, invalid_sha)
        end.to raise_error(Git::HeadChangedError)
      end
    end

    context 'creating a directory' do
      before do
        subject.commit_file(create(:git_commit_info,
                                   filepath: 'first_file',
                                   branch: branch))
      end

      let!(:path) { 'dir/with/subdir' }

      it 'raises an error' do
        expect do
          subject.mkdir(path, create(:git_commit_info, branch: branch),
                        invalid_sha)
        end.to raise_error(Git::HeadChangedError)
      end
    end
  end

  context 'when a file exists' do
    subject { create(:git) }
    let(:branch) { 'master' }

    context 'creating a directory' do
      let!(:path) { 'dir/with/subdir' }
      before do
        subject.commit_file(create(:git_commit_info,
                                   filepath: path,
                                   branch: branch))
      end

      it 'raises an error' do
        expect do
          subject.mkdir(path, create(:git_commit_info, branch: branch))
        end.to raise_error(Git::InvalidPathError, /as a file/)
      end
    end
  end

  context 'when a directory exists' do
    subject { create(:git) }
    let(:branch) { 'master' }

    context 'creating a directory' do
      let!(:path) { 'dir/with/subdir' }
      before do
        subject.commit_file(create(:git_commit_info,
                                   filepath: File.join(path, 'some_file'),
                                   branch: branch))
      end

      it 'raises an error' do
        expect do
          subject.mkdir(path, create(:git_commit_info, branch: branch))
        end.to raise_error(Git::InvalidPathError, /as a directory/)
      end
    end
  end
end
