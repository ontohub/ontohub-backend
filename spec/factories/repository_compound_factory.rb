# frozen_string_literal: true

FactoryGirl.define do
  factory :repository_compound do
    transient do
      repository { create(:repository) }
      git do
        create(:git, :with_commits,
               path: RepositoryCompound::GIT_DIRECTORY.
                 join("#{repository.to_param}.git"))
      end
    end
    skip_create
    initialize_with do
      # create the git repository
      git
      # create the repository and wrap it
      RepositoryCompound.wrap(repository)
    end
  end
end
