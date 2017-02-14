# frozen_string_literal: true

RSpec.describe(SettingsPresenceValidator) do
  let(:settings) { create :settings }
  subject { SettingsPresenceValidator.new(settings) }

  # Setup stubs
  before do
    # Don't print errors.
    allow(subject).to receive(:print_errors)

    # Don't shut down the system.
    allow(subject).to receive(:shutdown)

    # Don't complain about missing directories
    allow(File).to receive(:directory?).and_call_original
    [settings.data_directory].each do |dir|
      allow(File).to receive(:directory?).with(dir).and_return(true)
    end
  end

  it 'passes' do
    subject.call
    expect(subject.errors).to be_empty
  end

  context 'fails if the' do
    before { expect(subject).to receive(:shutdown) }

    it 'server_url is nil' do
      settings.server_url = nil
      subject.call
      expect(subject.errors).to include('server_url')
    end

    context 'jwt' do
      it 'expiration_hours is nil' do
        settings.jwt.expiration_hours = nil
        subject.call
        expect(subject.errors).to include('jwt.expiration_hours')
      end
    end

    it 'data_directory is nil' do
      settings.data_directory = nil
      subject.call
      expect(subject.errors).to include('data_directory')
    end
  end
end
