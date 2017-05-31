# frozen_string_literal: true

require 'fileutils'

namespace :apidoc do
  APIDOC_DIR = Rails.root.join('apidoc').to_s

  desc 'Prepare your system to build the API docs (this installs doca via npm).'
  task :prepare do
    system('npm', 'install', '-g', 'doca')
  end

  desc 'Build the API documentation app (requires npm and yarn).'
  task :init do
    source_dir = Rails.root.join('spec/support/api/schemas/apidoc').to_s
    doca_config =
      Rails.root.join('spec/support/api/schemas/doca_config.js').to_s
    FileUtils.rm_rf(APIDOC_DIR)
    system('doca', 'init', '-i', source_dir, '-o', APIDOC_DIR)
    Dir.chdir(APIDOC_DIR) do
      system('yarn')
    end
    FileUtils.cp(doca_config, File.join(APIDOC_DIR, 'config.js'))
  end

  desc "Run the API documentation server on port ENV['PORT'] (requires yarn)."
  task :run do
    Dir.chdir(APIDOC_DIR) do
      system('yarn', 'start')
    end
  end
end
