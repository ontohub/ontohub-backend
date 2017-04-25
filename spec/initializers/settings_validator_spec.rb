# frozen_string_literal: true

RSpec.describe(SettingsValidator) do
  let(:settings) { create :settings }
  subject { SettingsValidator.new(settings) }

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

    context 'server_url' do
      it 'is not a string' do
        settings.server_url = 0
        subject.call
        expect(subject.errors).to include('server_url')
      end

      it 'has a bad schema' do
        settings.server_url = 'gopher://example.com'
        subject.call
        expect(subject.errors).to include('server_url')
      end

      it 'has a path' do
        settings.server_url = 'http://example.com/some_path'
        subject.call
        expect(subject.errors).to include('server_url')
      end

      it 'has a query string' do
        settings.server_url = 'http://example.com?query_string'
        subject.call
        expect(subject.errors).to include('server_url')
      end

      it 'has a fragment' do
        settings.server_url = 'http://example.com#fragment'
        subject.call
        expect(subject.errors).to include('server_url')
      end

      it 'contains user info' do
        settings.server_url = 'http://user:pass@example.com'
        subject.call
        expect(subject.errors).to include('server_url')
      end
    end

    context 'jwt' do
      context 'expiration_hours' do
        it 'is not a Numeric type' do
          settings.jwt.expiration_hours = 'bad'
          subject.call
          expect(subject.errors).to include('jwt.expiration_hours')
        end
      end
    end

    context 'data_directory' do
      before do
        allow(File).
          to receive(:directory?).with(settings.data_directory).and_return(false)
      end

      it 'does not exist' do
        subject.call
        expect(subject.errors).to include('data_directory')
      end
    end
  end
end
