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

  def self.path
    instance_variable_get(:@tempdir)
  end

  def tempdir
    Tempdir.path
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
