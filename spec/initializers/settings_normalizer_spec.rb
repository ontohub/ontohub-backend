# frozen_string_literal: true

RSpec.describe(SettingsNormalizer) do
  let(:settings) { create :settings }
  subject { SettingsNormalizer.new(settings) }

  context 'normalize_paths' do
    shared_examples 'normalizing' do
      let(:relative_path) { 'relative/path' }

      it 'makes it a Pathname' do
        subject.call
        expect(settings.dig(*setting_path)).to be_a(Pathname)
      end

      it 'makes a relative path absolute' do
        setter.call(relative_path)
        subject.call
        expect(settings.dig(*setting_path).absolute?).to be(true)
      end

      it 'prepends Rails.root to a relative path' do
        setter.call(relative_path)
        subject.call
        expect(settings.dig(*setting_path)).
          to eq(Rails.root.join(relative_path))
      end

      it 'does not change an absolute path' do
        dir = File.join(Dir.pwd, relative_path)
        setter.call(dir)
        subject.call
        expect(settings.dig(*setting_path).to_s).to eq(dir)
      end
    end

    context 'on data_directory' do
      let(:setting_path) { %i(data_directory) }
      let(:setter) { ->(value) { settings[:data_directory] = value } }
      include_examples 'normalizing'
    end

    context 'on git_shell.path' do
      let(:setting_path) { %i(git_shell path) }
      let(:setter) { ->(value) { settings[:git_shell][:path] = value } }
      include_examples 'normalizing'
    end
  end

  context 'normalize_worker_groups' do
    it 'makes a classes string to an array' do
      subject.call
      expect(settings[:sneakers][0][:classes]).to be_a(Array)
    end
  end
end
