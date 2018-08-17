# frozen_string_literal: true

require 'fileutils'
namespace :apidoc do
  APIDOC_DIR = Rails.root.join('apidoc').to_s

  desc <<~DESC.tr("\n", ' ')
    Prepare your system to build the API docs (this installs doca via npm)
    (Step 1)
  DESC
  task :prepare do
    system('npm', 'install', '-g', 'doca')
  end

  desc <<~DESC.tr("\n", ' ')
    Build the API documentation app (requires npm and yarn)
    (Step 2)
  DESC
  task :init do
    source_dir = Rails.root.join('spec/support/api/schemas/rest').to_s
    doca_config =
      Rails.root.join('spec/support/api/schemas/doca_config.js').to_s
    FileUtils.rm_rf(APIDOC_DIR)
    system('doca', 'init', '-i', source_dir, '-o', APIDOC_DIR)
    Dir.chdir(APIDOC_DIR) do
      system('yarn')
    end
    FileUtils.cp(doca_config, File.join(APIDOC_DIR, 'config.js'))
  end

  desc <<~DESC.tr("\n", ' ')
    Run the API documentation server on port ENV['PORT'] (requires yarn)
    (Step 3)
  DESC
  task :run do
    port = ENV['PORT'] || '3002'
    pid = Kernel.fork do
      Dir.chdir(APIDOC_DIR) do
        Kernel.exec({'PORT' => port}, 'yarn', 'start')
      end
    end
    %w(INT TERM).each do |signal|
      Signal.trap(signal) do
        Process.kill(signal, pid)
        exit
      end
    end
    sleep
  end

  namespace :run do
    desc <<~DESC.tr("\n", ' ')
      Build the API documentation app and run the server on port ENV['PORT']
      (requires yarn).
    DESC
    task init: 'apidoc:init' do
      Rake::Task['apidoc:run'].invoke
    end
  end
end
