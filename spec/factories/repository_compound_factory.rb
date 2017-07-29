# frozen_string_literal: true

FactoryGirl.define do
  factory :repository_compound do
    transient do
      owner { create(:user) }
      repository { create(:repository, owner: owner) }
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

  # Returns the commit id
  factory :additional_commit, class: String do
    transient do
      repository { nil }
      user { create(:user) }
      branch { repository.git.default_branch }
      files { [] }
    end
    skip_create
    initialize_with do
      MultiBlob.new(user: user,
                    repository: repository,
                    branch: branch,
                    commit_message: generate(:commit_message),
                    files: files).save
    end
  end

  # Returns the commit id
  factory :additional_file, class: String do
    transient do
      repository { nil }
      path { generate(:filepath) }
      content { generate(:content) }
      encoding { 'plain' }
      branch { nil } # will be delegated to factory :additional_commit
      user { nil } # will be delegated to factory :additional_commit
    end
    skip_create
    initialize_with do
      files = [{path: path,
                content: content,
                encoding: encoding,
                action: 'create'}]
      options = {repository: repository, files: files}
      options[:branch] = branch if branch
      options[:user] = user if user
      create(:additional_commit, **options)
    end
  end
end
