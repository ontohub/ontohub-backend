# frozen_string_literal: true

FactoryBot.define do
  factory :repository_compound do
    transient do
      owner { create(:user) }
      public_access { true }
      repository do
        create(:repository, owner: owner, public_access: public_access)
      end
      git do
        create(:git,
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

  trait :private do
    public_access { false }
  end

  trait :not_empty do
    transient do
      git do
        create(:git, :with_commits,
               path: RepositoryCompound.git_directory.
                 join("#{repository.to_param}.git"))
      end
    end

    after(:create) do |repository|
      repository.git.log(ref: repository.git.default_branch).each do |commit|
        repository.git.diff_from_parent(commit.id).each do |diff|
          create(:file_version, repository: repository,
                                commit_sha: commit.id,
                                path: diff.new_path)
        end
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
      commit_message { generate(:commit_message) }
    end
    skip_create
    initialize_with do
      MultiBlob.new(user: user,
                    repository: repository,
                    branch: branch,
                    commit_message: commit_message,
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
      commit_message { nil } # will be delegated to factory :additional_commit
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
      options[:commit_message] = commit_message if commit_message
      create(:additional_commit, **options)
    end
  end

  factory :branch, class: String do
    transient do
      repository { nil }
      name { generate(:branchname) }
      revision { repository.git.default_branch }
    end
    skip_create
    initialize_with do
      repository.git.create_branch(name, revision)
    end
  end

  factory :tag, class: String do
    transient do
      repository { nil }
      name { generate(:tagname) }
      revision { repository.git.default_branch }
      message { nil }
      user { repository.owner }
    end
    skip_create
    initialize_with do
      if message.nil?
        repository.git.create_tag(name, revision)
      else
        repository.git.create_tag(name, revision,
          message: message, tagger: GitHelper.git_user(user))
      end
    end
  end
end
