# frozen_string_literal: true

module Tempdir
  def self.with_tempdir
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        instance_variable_set(:@tempdir, Pathname.new(dir))
        yield
      end
    end
  end

  # Call +Tempdir.path+ outside of an +it+ to get the current temp directory.
  def self.path
    # :nocov:
    # This is not yet used. Remove nocov as soon as it's used
    instance_variable_get(:@tempdir)
    # :nocov:
  end

  # Call +tempdir+ inside an +it+ to get the current temp directory.
  def tempdir
    # :nocov:
    # This is not yet used. Remove nocov as soon as it's used
    Tempdir.path
    # :nocov:
  end

  RSpec.configure do |config|
    config.include self
    config.around(:each) do |example|
      Tempdir.with_tempdir do
        example.run
      end
    end
  end
end
