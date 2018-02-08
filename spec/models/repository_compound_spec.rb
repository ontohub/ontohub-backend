# frozen_string_literal: true

RSpec.describe RepositoryCompound do
  subject { create(:repository_compound) }

  context 'class methods' do
    %i(find first).each do |method|
      context method do
        it 'finds the repository' do
          expect(RepositoryCompound.public_send(method, slug: subject.slug)).
            to eq(subject)
        end

        it 'returns nil if not found' do
          expect(RepositoryCompound.public_send(method, id: -1)).
            to be(nil)
        end
      end
    end

    context 'first!' do
      it 'finds the repository' do
        expect(RepositoryCompound.first!(id: subject.id)).to eq(subject)
      end

      it 'raises an error if not found' do
        expect { RepositoryCompound.first!(id: -1) }.
          to raise_error(Sequel::NoMatchingRow)
      end
    end

    context 'wrap' do
      let(:repository) { subject.repository }

      it 'wraps the repository' do
        expect(RepositoryCompound.wrap(repository)).to eq(subject)
      end
    end

    context 'git_directory' do
      it 'is a Pathname' do
        expect(RepositoryCompound.git_directory).to be_a(Pathname)
      end
    end

    context 'new' do
      let(:owner) { create(:user) }
      let(:attributes) { attributes_for(:repository).merge(owner_id: owner.id) }

      it 'builds a RepositoryCompound' do
        expect(RepositoryCompound.new(attributes)).to be_a(RepositoryCompound)
      end

      it 'builds a Repository' do
        expect(RepositoryCompound.new(attributes).repository).
          to be_a(Repository)
      end

      it 'sets the repository attributes' do
        expect(RepositoryCompound.new(attributes).repository.values).
          to include(attributes)
      end
    end
  end

  context 'save' do
    let(:owner) { create(:user) }
    let(:attributes) { attributes_for(:repository).merge(owner_id: owner.id) }
    subject { RepositoryCompound.new(attributes) }
    before { subject.save }

    it 'creates a Repository' do
      expect(Repository.first!(id: subject.id)).to eq(subject.repository)
    end

    it 'creates a git repository' do
      expect(subject.git.repo_exists?).to be(true)
    end

    context 'on an existing object' do
      before do
        allow(subject.repository).to receive(:save).and_call_original
      end

      it 'does not raise an error' do
        expect { subject.save }.not_to raise_error
      end

      it 'saves the inner repository' do
        subject.save
        expect(subject.repository).to have_received(:save)
      end

      %w(update post-receive).each do |hook|
        it "creates the #{hook} hook" do
          subject.save
          file = File.join(subject.git.path, 'hooks', hook)
          expect(File.file?(file) && File.executable?(file)).
            to be(true)
        end
      end
    end
  end

  context 'destroy' do
    subject { create(:repository_compound) }
    let!(:id) { subject.repository.id }
    let!(:git) { subject.git }
    before { subject.destroy }

    it 'deletes the Repository' do
      expect(Repository.first(id: id)).to be(nil)
    end

    it 'removes the git repository' do
      expect(git.repo_exists?).to be(false)
    end
  end

  context '==' do
    it 'detects equality' do
      expect(subject).to eq(RepositoryCompound.first!(id: subject.id))
    end

    it 'detects inequality' do
      expect(subject).not_to eq(create(:repository_compound))
    end
  end
end
