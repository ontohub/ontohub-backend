# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Blob do
  # Attributes to check for equality
  attributes = %i(content path)

  subject { build :blob }

  context 'attributes' do
    %i(branch commit_message previous_head_sha previous_path user
       commit_id id
       content encoding path repository).each do |attribute|
      it "contain a getter for #{attribute}" do
        expect(subject).to respond_to(attribute)
      end

      it "contain a setter for #{attribute}" do
        expect(subject).to respond_to("#{attribute}=")
      end
    end
  end

  context '.find after' do
    context '#create' do
      context 'plain text with plain text encoding' do
        before { subject.create }

        context 'can be found again' do
          let(:found_blob) do
            Blob.find(branch: subject.branch,
                      repository_id: subject.repository.to_param,
                      path: subject.path)
          end

          attributes.each do |attribute|
            it "and has the correct #{attribute}" do
              expect(found_blob.send(attribute)).to eq(subject.send(attribute))
            end
          end
        end

        context 'on a non-existent branch' do
          it 'returns nil' do
            found = Blob.find(branch: 'branch-that-does-not-exist',
                              repository_id: subject.repository.to_param,
                              path: subject.path)
            expect(found).to be(nil)
          end
        end

        context 'after deleting and recreating' do
          let!(:new_blob) do
            build(:blob, branch: subject.branch,
                         repository: subject.repository,
                         path: subject.path)
          end
          before { subject.destroy }

          it 'does not raise an error' do
            expect { new_blob.create }.not_to raise_error
          end
        end
      end

      context 'plain text with base64 text encoding' do
        let!(:original_content) { subject.content }
        before do
          subject.content = Base64.strict_encode64(subject.content)
          subject.encoding = 'base64'
          subject.create
        end

        context 'can be found again' do
          let(:found_blob) do
            Blob.find(branch: subject.branch,
                      repository_id: subject.repository.to_param,
                      path: subject.path)
          end

          it 'and has the correct content' do
            expect(found_blob.content).to eq(original_content)
          end

          it 'and has the correct encoding' do
            expect(found_blob.encoding).to eq('plain')
          end
        end
      end

      context 'binary data with base64 encoding' do
        let!(:bitmap) do
          # rubocop:disable Metrics/LineLength
          "Qk18AAAAAAAAAHYAAAAoAAAAAQAAAAEAAAABAAQAAAAAAAYAAAAsLgAALC4A\nAAAAAAAAAAAAAAAAABEREQAiIiIAMzMzAERERABVVVUAZmZmAHd3dwCIiIgA\nmZmZAKqqqgC7u7sAzMzMAN3d3QDu7u4A////APAAAAAAAA==\n"
          # rubocop:enable Metrics/LineLength
        end
        before do
          subject.path = "#{subject.path}.1by1pixel_white.bmp"
          subject.content = bitmap
          subject.encoding = 'base64'
          subject.create
        end

        context 'can be found again' do
          let(:found_blob) do
            Blob.find(branch: subject.branch,
                      repository_id: subject.repository.to_param,
                      path: subject.path)
          end

          it 'and has the correct content' do
            expect(found_blob.content).to eq(subject.content)
          end

          it 'and has the correct encoding' do
            expect(found_blob.encoding).to eq('base64')
          end
        end
      end

      context 'if the path already exists' do
        let(:old_blob) do
          build(:blob,
                repository: subject.repository,
                branch: subject.branch,
                path: subject.path)
        end
        before { old_blob.create }

        it 'raises an error' do
          expect { subject.create }.to raise_error(Blob::ValidationFailed)
        end
      end

      context 'if no user is specified' do
        before do
          subject.update(user: nil)
        end

        it 'raises an error' do
          expect { subject.create }.to raise_error(Blob::ValidationFailed)
        end
      end

      context 'if no commit_message is specified' do
        before do
          subject.update(commit_message: nil)
        end

        it 'raises an error' do
          expect { subject.create }.to raise_error(Blob::ValidationFailed)
        end
      end

      context 'if no repository is specified' do
        before do
          subject.update(repository: nil)
        end

        it 'raises an error' do
          expect { subject.create }.to raise_error(Blob::ValidationFailed)
        end
      end
    end

    context '#update' do
      let(:old_blob) do
        build(:blob,
              repository: subject.repository,
              branch: subject.branch,
              path: subject.path,
              content: "previous #{subject.content}")
      end
      before { old_blob.create }
      let(:new_blob) do
        blob = Blob.find(branch: old_blob.branch,
                         repository_id: old_blob.repository.to_param,
                         path: old_blob.path)
        blob.commit_message = 'update'
        blob.user = old_blob.user
        blob
      end

      context 'to change content' do
        before do
          new_blob.
            update(branch: old_blob.branch,
                   content: new_blob.content.sub('previous ', ''))
          new_blob.save
        end

        context 'can be found again' do
          let(:found_blob) do
            Blob.find(branch: new_blob.branch,
                      repository_id: new_blob.repository.to_param,
                      path: new_blob.path)
          end

          attributes.each do |attribute|
            it "and has the correct #{attribute}" do
              expect(found_blob.send(attribute)).
                to eq(new_blob.send(attribute))
            end
          end
        end
      end

      context 'to rename the file' do
        before do
          new_blob.update(path: "#{new_blob.path}.new")
          new_blob.save
        end

        context 'can be found again' do
          let(:found_blob) do
            Blob.find(branch: new_blob.branch,
                      repository_id: new_blob.repository.to_param,
                      path: new_blob.path)
          end

          attributes.each do |attribute|
            it "and has the correct #{attribute}" do
              expect(found_blob.send(attribute)).
                to eq(new_blob.send(attribute))
            end
          end
        end

        context 'the previous file can be found again in the previous ref' do
          let(:found_blob) do
            Blob.find(branch: "#{subject.branch}~1",
                      repository_id: old_blob.repository.to_param,
                      path: old_blob.path)
          end

          attributes.each do |attribute|
            it "and has the correct #{attribute}" do
              expect(found_blob.send(attribute)).to eq(old_blob.send(attribute))
            end
          end
        end
      end
    end

    context '#destroy' do
      before do
        subject.create
        subject.destroy
      end

      it 'can not be found again' do
        found_blob =
          Blob.find(branch: subject.branch,
                    repository_id: subject.repository.to_param,
                    path: subject.path)
        expect(found_blob).to be(nil)
      end

      context 'the previous file can be found again in the previous ref' do
        let(:found_blob) do
          Blob.find(branch: "#{subject.branch}~1",
                    repository_id: subject.repository.to_param,
                    path: subject.path)
        end

        attributes.each do |attribute|
          it "and has the correct #{attribute}" do
            expect(found_blob.send(attribute)).to eq(subject.send(attribute))
          end
        end
      end
    end
  end

  context 'supplying a previous_head_sha' do
    let(:old_blob) do
      build(:blob,
             repository: subject.repository,
             branch: subject.branch)
    end
    before { old_blob.create }
    let(:new_blob) do
      blob = Blob.find(repository: old_blob.repository,
                       branch: old_blob.branch,
                       path: old_blob.path)
      blob.commit_message = 'update'
      blob.user = old_blob.user
      blob.update(content: "new #{old_blob.content}", encoding: 'plain')
      blob
    end

    context 'that matches the real commit_id of the HEAD' do
      let(:previous_head_sha) { old_blob.commit_id }
      before { new_blob.previous_head_sha = previous_head_sha }

      it 'passes' do
        expect { new_blob.save }.not_to raise_error
      end
    end

    context 'that does not match the real commit_id of the HEAD' do
      let(:previous_head_sha) { '0' * 39 }
      before { new_blob.previous_head_sha = previous_head_sha }

      it 'raises a ValidationError' do
        expect { new_blob.save }.to raise_error(Blob::ValidationFailed)
      end

      it 'raises a ValidationError' do
        begin
          new_blob.save
        rescue Blob::ValidationFailed
          expect(new_blob.errors[:branch]).not_to be_empty
        end
      end
    end
  end

  context '#url' do
    before do
      subject.create
      subject.destroy
    end

    it 'is correct' do
      expect(subject.url(Settings.server_url)).
        to eq("#{Settings.server_url}/#{subject.repository.to_param}"\
              "/ref/#{subject.commit_id}/tree/#{subject.path}")
    end
  end

  context '#url_path' do
    before do
      subject.create
      subject.destroy
    end

    it 'is correct' do
      expect(subject.url_path).
        to eq("/#{subject.repository.to_param}"\
              "/ref/#{subject.commit_id}/tree/#{subject.path}")
    end
  end

  context 'FileVersion' do
    it 'creates a FileVersion on creation' do
      # rubocop:disable Style/MultilineBlockLayout
      # rubocop:disable Style/BlockEndNewline
      expect { subject.create }.
        to change { FileVersion.find(commit_sha: subject.commit_id,
                                     path: subject.path).nil? }.
        from(true).to(false)
      # rubocop:enable Style/MultilineBlockLayout
      # rubocop:enable Style/BlockEndNewline
    end

    it 'does not delete the previous FileVersion on deletion' do
      subject.create

      git = subject.repository.git
      commit_sha_after_creation = git.branch_sha(git.default_branch)

      # rubocop:disable Style/MultilineBlockLayout
      # rubocop:disable Style/BlockEndNewline
      # rubocop:disable Lint/AmbiguousBlockAssociation
      expect { subject.destroy }.
        not_to change { FileVersion.find(commit_sha: commit_sha_after_creation,
                                         path: subject.path).nil? }
      # rubocop:enable Style/MultilineBlockLayout
      # rubocop:enable Style/BlockEndNewline
      # rubocop:enable Lint/AmbiguousBlockAssociation
    end
  end
end
