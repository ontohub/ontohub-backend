# frozen_string_literal: true

FactoryGirl.define do
  factory :repository_compound do
    transient do
      repository { create(:repository) }
      git do
        create(:git, :with_commits,
               path: RepositoryCompound.git_directory.
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

  trait :empty_git do
    transient do
      git do
        create(:git,
               path: RepositoryCompound.git_directory.
                 join("#{repository.to_param}.git"))
      end
    end
  end
end
