# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples "a commit's author/committer in GraphQL" do
  let(:expected_object) do
    GitUser.new(subject.send("#{person}_name"),
                subject.send("#{person}_email"))
  end

  before do
    allow(expected_object).to receive(:account).and_return(account)
  end

  %i(name email account).each do |field|
    it "returns the correct #{field}" do
      expect(resolved_field.send(field)).to eq(expected_object.send(field))
    end
  end
end

RSpec.shared_examples "a commit's file in GraphQL" do
  let(:received) do
    received = {}
    %i(name path size loaded_size content encoding).each do |attribute|
      received[attribute] = resolved_field.public_send(attribute)
    end
    received
  end

  context 'that is small' do
    it 'shows the file' do
      expect(received).
        to eq(name: blob.name,
              path: path,
              size: blob.size,
              loaded_size: blob.size,
              content: binary ? Base64.encode64(blob.data) : blob.data,
              encoding: expected_encoding)
    end
  end

  context 'that is large' do
    before { stub_const('Gitlab::Git::Blob::MAX_DATA_DISPLAY_SIZE', 1) }

    context 'without loadAllData' do
      it 'shows the truncated file' do
        content = blob.data[0..Gitlab::Git::Blob::MAX_DATA_DISPLAY_SIZE - 1]
        expect(received).
          to eq(name: blob.name,
                path: path,
                size: blob.size,
                loaded_size: Gitlab::Git::Blob::MAX_DATA_DISPLAY_SIZE,
                content: binary ? Base64.encode64(content) : content,
                encoding: expected_encoding)
      end
    end

    context 'with loadAllData' do
      let(:arguments) do
        {'path' => path,
         'loadAllData' => true}
      end
      it 'shows the file' do
        expect(received).
          to eq(name: blob.name,
                path: path,
                size: blob.size,
                loaded_size: blob.size,
                content: binary ? Base64.encode64(blob.data) : blob.data,
                encoding: expected_encoding)
      end
    end
  end
end

RSpec.shared_examples "a commit's document in GraphQL" do
  it 'finds the document' do
    expect(resolved_field).to eq(document)
  end
end

RSpec.describe Types::Git::CommitType do
  let(:repository) { create(:repository_compound, :not_empty) }
  let(:revision) { repository.git.default_branch }
  subject { repository.git.commit(revision) }
  let(:file_version) { FileVersion.find(commit_sha: subject.id) }
  let(:type) { OntohubBackendSchema.types['Commit'] }
  let(:arguments) { {} }
  let(:resolved_field) { field.resolve(subject, arguments, {}) }
  let(:binary) { false }

  context 'author field' do
    let(:person) { 'author' }
    let(:field) { type.get_field('author') }

    context 'with a corresponding user' do
      let!(:account) { create(:user, email: subject.send("#{person}_email")) }
      it_behaves_like "a commit's author/committer in GraphQL"
    end

    context 'without a corresponding user' do
      let!(:account) { nil }
      it_behaves_like "a commit's author/committer in GraphQL"
    end
  end

  context 'committer field' do
    let(:person) { 'committer' }
    let(:field) { type.get_field('committer') }

    context 'with a corresponding user' do
      let!(:account) { create(:user, email: subject.send("#{person}_email")) }
      it_behaves_like "a commit's author/committer in GraphQL"
    end

    context 'without a corresponding user' do
      let!(:account) { nil }
      it_behaves_like "a commit's author/committer in GraphQL"
    end
  end

  context 'directory field' do
    let(:field) { type.get_field('directory') }
    let(:arguments) { {'path' => path} }
    before do
      # Create a file in the root directory. A subdirectory already exists.
      filepath = File.basename(Faker::File.file_name(nil, nil, 'txt'))
      create(:additional_file, repository: repository,
                               branch: revision,
                               path: filepath)
    end

    context 'existing directory' do
      let(:path) { '/' }

      it 'lists all directories and files' do
        index = repository.git.tree(revision, path).map do |tree|
          if tree.type == :tree
            GitDirectory.new(subject, tree.path, tree.name)
          else
            GitFile.new(subject, tree.path)
          end
        end
        received = resolved_field.map { |e| {path: e.path, kind: e.kind} }
        expected = index.map { |e| {path: e.path, kind: e.kind} }
        expect(received).to match_array(expected)
      end
    end

    context 'inexistant directory' do
      let(:path) { '/inexistant' }

      it 'is nil' do
        expect(resolved_field).to be(nil)
      end
    end
  end

  context 'file field' do
    let(:field) { type.get_field('file') }
    let(:arguments) { {'path' => path} }
    let(:blob) do
      blob = repository.git.blob(revision, path)
      blob.load_all_data!
      blob
    end

    context 'on a text file' do
      let(:path) { repository.git.ls_files(revision).first }
      let(:expected_encoding) { 'plain' }
      it_behaves_like "a commit's file in GraphQL"
    end

    context 'on a binary file' do
      let(:binary) { true }
      let!(:bitmap) do
        <<~BITMAP
          Qk18AAAAAAAAAHYAAAAoAAAAAQAAAAEAAAABAAQAAAAAAAYAAAAsLgAALC4A
          AAAAAAAAAAAAAAAAABEREQAiIiIAMzMzAERERABVVVUAZmZmAHd3dwCIiIgA
          mZmZAKqqqgC7u7sAzMzMAN3d3QDu7u4A////APAAAAAAAA==
        BITMAP
      end
      let(:path) { Faker::File.file_name(nil, nil, 'bmp') }
      let(:expected_encoding) { 'base64' }
      before do
        create(:additional_file, repository: repository,
                                 branch: revision,
                                 path: path,
                                 content: bitmap,
                                 encoding: 'base64')
      end
      it_behaves_like "a commit's file in GraphQL"
    end
  end

  context 'document field' do
    let(:field) { type.get_field('document') }
    let(:arguments) { {'locId' => loc_id} }
    let(:loc_id) { document.loc_id }

    context 'on a Library' do
      let!(:document) { create(:library, file_version: file_version) }
      it_behaves_like "a commit's document in GraphQL"
    end

    context 'on a NativeDocument' do
      let!(:document) { create(:native_document, file_version: file_version) }
      it_behaves_like "a commit's document in GraphQL"
    end
  end

  context 'ls_files field' do
    let(:field) { type.get_field('lsFiles') }
    before do
      5.times { create :additional_file, repository: repository }
    end

    it 'lists all files in the repository' do
      expect(resolved_field).to match_array(repository.git.ls_files(revision))
    end
  end

  context 'diff field' do
    let(:field) { type.get_field('diff') }

    %i(a_mode b_mode deleted_file diff line_count new_file new_path old_path
       renamed_file).each do |attribute|
      it "matches each diff of the commit in #{attribute}" do
        subject.diffs.each_with_index do |diff, index|
          expect(resolved_field[index].public_send(attribute)).
            to eq(diff.public_send(attribute))
        end
      end
    end
  end
end
