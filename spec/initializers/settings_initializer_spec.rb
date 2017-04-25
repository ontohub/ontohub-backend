# frozen_string_literal: true

RSpec.describe(SettingsInitializer) do
  let(:settings) { create :settings }
  subject { SettingsInitializer.new(settings) }

  it 'creates the data directory' do
    settings.data_directory = File.join(Dir.pwd, 'data')
    expect { subject.call }.
      to change { File.directory?(settings.data_directory) }.
      from(false).to(true)
  end
end
