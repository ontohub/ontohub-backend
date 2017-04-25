# frozen_string_literal: true

namespace :repo do
  desc 'Remove the git repository directory.'
  task clean: :environment do
    git_dir = Settings.data_directory.join('git').freeze
    git_dir.rmtree if git_dir.exist?
  end
end
