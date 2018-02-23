# frozen_string_literal: true

namespace :repo do
  desc 'Remove the git repository directory.'
  task clean: :environment do
    git_dir = Settings.data_directory.join('git').freeze
    git_dir.rmtree if git_dir.exist?
  end

  desc 'Recreate all git hooks (needed when the git_shell.path setting changed)'
  task recreate_hooks: :environment do
    Repository.each do |repository|
      RepositoryCompound.wrap(repository).recreate_hooks
    end
  end
end
