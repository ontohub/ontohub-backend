# frozen_string_literal: true

require 'base64'
require 'rails_helper'

RSpec.describe MultiBlob do
  context 'attributes' do
    %i(branch commit_message files last_known_head_id repository user
       decorated_file_versions commit_sha).each do |attribute|
      it "contain a getter for #{attribute}" do
        expect(subject).to respond_to(attribute)
      end

      it "contain a setter for #{attribute}" do
        expect(subject).to respond_to("#{attribute}=")
      end
    end
  end

  context 'save' do
    let!(:repository) { create(:repository_compound) }
    let!(:git) { repository.git }
    let!(:branch) { 'master' }
    let!(:user) { create(:user) }
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
      commit_sha = git.commit_multichange(info)
      old_files.each do |old_file|
        FileVersion.create(repository_id: repository.id,
                           commit_sha: commit_sha,
                           path: old_file)
      end
      commit_sha
    end
    let(:files) do
      [{path: new_files[0],
        content: new_contents[0],
        encoding: 'plain',
        action: 'create'},

       {new_path: new_files[1],
        path: old_files[1],
        action: 'rename'},

       {path: old_files[2],
        content: new_contents[2],
        encoding: 'plain',
        action: 'update'},

       {new_path: new_files[3],
        path: old_files[3],
        content: new_contents[3],
        encoding: 'plain',
        action: 'rename_and_update'},

       {path: old_files[4],
        action: 'remove'},

       {path: new_files[5],
        action: 'mkdir'}]
    end
    let(:valid_options) do
      {files: files,
       commit_message: generate(:commit_message),
       branch: branch,
       repository: repository,
       user: user}
    end

    context 'successful' do
      context 'plain encoding given' do
        subject { MultiBlob.new(valid_options) }

        it 'is successful' do
          expect(subject.save).to match(/\A[0-9a-f]{40}\z/)
        end
      end

      context 'base64 encoding given' do
        subject do
          MultiBlob.new(valid_options.
            merge(files: [{path: new_files[0],
                           content: Base64.encode64(new_contents[0]),
                           encoding: 'base64',
                           action: 'create'}]))
        end

        it 'is successful' do
          expect(subject.save).to match(/\A[0-9a-f]{40}\z/)
        end
      end
    end

    context 'with a last_known_head_id' do
      context 'successful' do
        subject do
          MultiBlob.new(valid_options.
            merge(files: [{path: new_files[0],
                           content: new_contents[0],
                           encoding: 'plain',
                           action: 'create'}],
                  last_known_head_id: setup_commit))
        end

        it 'is successful' do
          expect(subject.save).to match(/\A[0-9a-f]{40}\z/)
        end
      end

      context 'failing' do
        context 'bad last_known_head_id' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: new_files[0],
                             content: new_contents[0],
                             encoding: 'plain',
                             action: 'create'}],
                    last_known_head_id: '0' * 40))
          end

          it 'raises an error' do
            expect { subject.save }.to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:last_known_head_id].first).
                to match(/reference could not be found/i)
            end
          end
        end

        context 'merge conflict' do
          let(:previous_commit) { MultiBlob.new(valid_options).save }
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: old_files[2],
                             content: new_contents[2].upcase,
                             encoding: 'plain',
                             action: 'update'}],
                    last_known_head_id: setup_commit))
          end

          before do
            previous_commit
            subject
          end

          it 'raises an error' do
            expect { subject.save }.to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:branch].first).
                to match(/changed in the meantime/i)
            end
          end

          it 'contains the conflicts including the merge info' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed => error
              merge_info =
                {
                  automergeable: false,
                  path: old_files[2],
                  filemode: be > 0,
                  data: match(/<{7}.*={7}.*>{7}/m),
                }
              expect(error.conflicts).
                to match_array([{ancestor: be_a(Hash),
                                 ours: be_a(Hash),
                                 theirs: be_a(Hash),
                                 merge_info: merge_info}])
            end
          end
        end
      end
    end

    context 'with validation errors' do
      context 'create' do
        let(:action) { 'create' }

        context 'no path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: '',
                             content: new_contents[0],
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/must be present/)
            end
          end
        end

        context 'existing path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: old_files[0],
                             content: new_contents[0],
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/path already exists/)
            end
          end
        end

        context 'no content' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: new_files[0],
                             content: nil,
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/content"].first).
                to match(/must exist/)
            end
          end
        end

        context 'content not a string' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: new_files[0],
                             content: 0,
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/content"].first).
                to match(/must be a string/)
            end
          end
        end

        context 'unsupported encoding' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: new_files[0],
                             content: new_contents[0],
                             encoding: 'bad encoding',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/encoding"].first).
                to match(/encoding not supported/)
            end
          end
        end
      end

      context 'update' do
        let(:action) { 'update' }

        context 'no path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: '',
                             content: new_contents[0],
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/must be present/)
            end
          end
        end

        context 'non-existent path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: new_files[0],
                             content: new_contents[0],
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/path does not exist/)
            end
          end
        end

        context 'without content' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: old_files[0],
                             content: nil,
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/content"].first).
                to match(/must exist/)
            end
          end
        end

        context 'content not a string' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: new_files[0],
                             content: 0,
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/content"].first).
                to match(/must be a string/)
            end
          end
        end

        context 'unsupported encoding' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: new_files[0],
                             content: new_contents[0],
                             encoding: 'bad encoding',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/encoding"].first).
                to match(/encoding not supported/)
            end
          end
        end
      end

      context 'rename_and_update' do
        let(:action) { 'rename_and_update' }

        context 'no new_path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: '',
                             path: old_files[0],
                             content: new_contents[0],
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/new_path"].first).
                to match(/must be present/)
            end
          end
        end

        context 'no path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: new_files[0],
                             path: '',
                             content: new_contents[0],
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/must be present/)
            end
          end
        end

        context 'non-existent path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: new_files[1],
                             path: new_files[0],
                             content: new_contents[0],
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/path does not exist/)
            end
          end
        end

        context 'path matches new_path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: old_files[0],
                             path: old_files[0],
                             content: new_contents[0],
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/new_path"].first).
                to match(/path and new_path must differ/)
            end
          end
        end

        context 'without content' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: old_files[0],
                             path: old_files[0],
                             content: nil,
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/content"].first).
                to match(/must exist/)
            end
          end
        end

        context 'no content' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: new_files[0],
                             path: old_files[0],
                             content: nil,
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/content"].first).
                to match(/must exist/)
            end
          end
        end

        context 'content not a string' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: new_files[0],
                             path: old_files[0],
                             content: 0,
                             encoding: 'plain',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/content"].first).
                to match(/must be a string/)
            end
          end
        end

        context 'unsupported encoding' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: new_files[0],
                             path: old_files[0],
                             content: new_contents[0],
                             encoding: 'bad encoding',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/encoding"].first).
                to match(/encoding not supported/)
            end
          end
        end
      end

      context 'rename' do
        let(:action) { 'rename' }

        context 'no new_path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: '',
                             path: old_files[0],
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/new_path"].first).
                to match(/must be present/)
            end
          end
        end

        context 'no path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: new_files[0],
                             path: '',
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/must be present/)
            end
          end
        end

        context 'non-existent path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: new_files[0],
                             path: new_files[1],
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/path does not exist/)
            end
          end
        end

        context 'path matches new_path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{new_path: old_files[0],
                             path: old_files[0],
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/new_path"].first).
                to match(/path and new_path must differ/)
            end
          end
        end
      end

      context 'remove' do
        let(:action) { 'remove' }

        context 'non-existent path' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: new_files[0],
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/path does not exist/)
            end
          end
        end
      end

      context 'mkdir' do
        let(:action) { 'mkdir' }

        context 'path already exists' do
          subject do
            MultiBlob.new(valid_options.
              merge(files: [{path: old_files[0],
                             action: action}]))
          end

          it 'is invalid' do
            expect { subject.save }.
              to raise_error(MultiBlob::ValidationFailed)
          end

          it 'has the correct error message' do
            begin
              subject.save
            rescue MultiBlob::ValidationFailed
              expect(subject.errors.messages[:"files/0/path"].first).
                to match(/path already exists/)
            end
          end
        end
      end

      context 'no repository' do
        subject do
          MultiBlob.new(valid_options.merge(repository: nil))
        end

        it 'is invalid' do
          expect { subject.save }.
            to raise_error(MultiBlob::ValidationFailed)
        end

        it 'has the correct error message' do
          begin
            subject.save
          rescue MultiBlob::ValidationFailed
            expect(subject.errors.messages[:repository].first).
              to match(/must be a repository/)
          end
        end
      end

      context 'no user' do
        subject do
          MultiBlob.new(valid_options.merge(user: nil))
        end

        it 'is invalid' do
          expect { subject.save }.
            to raise_error(MultiBlob::ValidationFailed)
        end

        it 'has the correct error message' do
          begin
            subject.save
          rescue MultiBlob::ValidationFailed
            expect(subject.errors.messages[:user].first).
              to match(/must be a user/)
          end
        end
      end

      context 'bad branch' do
        subject do
          MultiBlob.new(valid_options.merge(branch: "bad-#{branch}"))
        end

        it 'is invalid' do
          expect { subject.save }.
            to raise_error(MultiBlob::ValidationFailed)
        end

        it 'has the correct error message' do
          begin
            subject.save
          rescue MultiBlob::ValidationFailed
            expect(subject.errors.messages[:branch].first).
              to match(/branch does not exist/)
          end
        end
      end

      context 'no commit message' do
        subject do
          MultiBlob.new(valid_options.merge(commit_message: ''))
        end

        it 'is invalid' do
          expect { subject.save }.
            to raise_error(MultiBlob::ValidationFailed)
        end

        it 'has the correct error message' do
          begin
            subject.save
          rescue MultiBlob::ValidationFailed
            expect(subject.errors.messages[:commit_message].first).
              to match(/must be present/)
          end
        end
      end
    end

    context 'FileVersion' do
      subject { MultiBlob.new(valid_options) }
      let!(:commit_sha) { subject.save }

      it 'creates a FileVersion for the created file' do
        expect(FileVersion.first(commit_sha: commit_sha, path: new_files[0])).
          to be_a(FileVersion)
      end

      it 'creates a FileVersion for the renamed file' do
        expect(FileVersion.first(commit_sha: commit_sha, path: new_files[1])).
          to be_a(FileVersion)
      end

      it 'creates a FileVersion for the updated file' do
        expect(FileVersion.first(commit_sha: commit_sha, path: old_files[2])).
          to be_a(FileVersion)
      end

      it 'creates a FileVersion for the updated and renamed file' do
        expect(FileVersion.first(commit_sha: commit_sha, path: new_files[3])).
          to be_a(FileVersion)
      end

      it 'does not create a FileVersion for the removed file' do
        expect(FileVersion.first(commit_sha: commit_sha, path: old_files[4])).
          to be(nil)
      end

      it 'creates a FileVersion for the created .gitkeep file' do
        expect(FileVersion.first(commit_sha: commit_sha,
                                path: File.join(new_files[5], '.gitkeep'))).
          to be_a(FileVersion)
      end
    end

    context 'FileVersionParent' do
      subject { MultiBlob.new(valid_options) }
      it 'enqueues a post-processing job' do
        commit_sha = subject.save
        expect(ProcessCommitJob).
          to have_been_enqueued.
          with(subject.repository.id, commit_sha)
      end
    end
  end
end
