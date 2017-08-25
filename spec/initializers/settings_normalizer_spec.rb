# frozen_string_literal: true

RSpec.describe(SettingsNormalizer) do
  let(:settings) { create :settings }
  subject { SettingsNormalizer.new(settings) }

  context 'normalize_paths' do
    context 'on data_directory' do
      let(:relative_path) { 'relative/path' }

      it 'makes it a Pathname' do
        subject.call
        expect(settings.data_directory).to be_a(Pathname)
      end

      it 'makes a relative path absolute' do
        settings.data_directory = relative_path
        subject.call
        expect(settings.data_directory.absolute?).to be(true)
      end

      it 'prepends Rails.root to a relative path' do
        settings.data_directory = relative_path
        subject.call
        expect(settings.data_directory).to eq(Rails.root.join(relative_path))
      end

      it 'does not change an absolute path' do
        dir = File.join(Dir.pwd, relative_path)
        settings.data_directory = dir
        subject.call
        expect(settings.data_directory.to_s).to eq(dir)
      end
    end
  end

  context 'normalize_worker_groups' do
    it 'makes a classes string to an array' do
      subject.call
      expect(settings.sneakers[0].classes).to be_a(Array)
    end
  end
end
