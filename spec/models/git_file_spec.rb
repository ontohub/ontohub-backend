# frozen_string_literal: true

RSpec.describe GitFile do
  let!(:repository) { create(:repository_compound, :not_empty) }
  let(:git) { repository.git }
  let(:commit) { git.commit(git.default_branch) }

  let(:existing_filepath) { git.ls_files(commit.id).first }

  let(:path) { existing_filepath }
  let(:real_name) { File.basename(existing_filepath) }
  let(:load_all_data) { false }

  let(:name) { nil }

  subject do
    GitFile.new(commit,
                path,
                name: name,
                load_all_data: load_all_data)
  end

  before do
    allow_any_instance_of(GitFile).to receive(:blob).and_call_original
  end

  context 'exist?' do
    context 'on an existing file' do
      let(:path) { existing_filepath }

      it 'is true' do
        expect(subject.exist?).to be(true)
      end

      it 'loads the blob' do
        subject.exist?
        expect(subject).to have_received(:blob).at_least(:once)
      end
    end

    context 'on an inexistant file' do
      let(:path) { "bad-#{existing_filepath}" }

      it 'is true' do
        expect(subject.exist?).to be(false)
      end

      it 'loads the blob' do
        subject.exist?
        expect(subject).to have_received(:blob).at_least(:once)
      end
    end
  end

  context 'lazy evaluation' do
    context 'with a name supplied' do
      let(:name) { real_name }

      it 'does not load the blob' do
        expect_any_instance_of(GitFile).not_to receive(:blob)
        subject.name
        subject.path
      end
    end

    context 'without a name supplied' do
      let(:name) { nil }

      it 'loads the blob' do
        subject.name
        subject.path
        expect(subject).to have_received(:blob).at_least(:once)
      end
    end
  end

  context 'loading all data' do
    before { stub_const('Gitlab::Git::Blob::MAX_DATA_DISPLAY_SIZE', 1) }

    context 'with load_all_data set to true' do
      let(:load_all_data) { true }

      it 'reports the correct size' do
        expect(subject.loaded_size).to eq(subject.size)
      end

      it 'has the correct content length' do
        expect(subject.content.length).to eq(subject.loaded_size)
      end

      it 'has more content than the limit' do
        expect(subject.loaded_size).
          to be > Gitlab::Git::Blob::MAX_DATA_DISPLAY_SIZE
      end
    end

    context 'with load_all_data set to false' do
      let(:load_all_data) { false }

      it 'reports the correct size' do
        expect(subject.loaded_size).
          to eq(Gitlab::Git::Blob::MAX_DATA_DISPLAY_SIZE)
      end

      it 'has the correct content length' do
        expect(subject.content.length).to eq(subject.loaded_size)
      end

      it 'has only the limited content' do
        expect(subject.loaded_size).
          to eq(Gitlab::Git::Blob::MAX_DATA_DISPLAY_SIZE)
      end
    end
  end
end
