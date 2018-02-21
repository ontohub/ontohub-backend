# frozen_string_literal: true

namespace :index do
  desc 'Clear all indexes'
  task clear: :environment do
    [Index::RepositoryIndex,
     Index::OrganizationIndex,
     Index::UserIndex].each(&:delete)
  end
end