# frozen_string_literal: true

FactoryGirl.define do
  sequence(:git_user) do |n|
    {email: "git-user-#{n}@example.com",
     name: "git-user#-#{n}",
     time: Time.now}
  end

  sequence(:commit_message) do |n|
    "#{n}: #{Faker::Lorem.sentence}"
  end

  sequence(:content) do |n|
    "#{n}: #{Faker::Lorem.sentence}\n"
  end

  sequence(:branchname) do |n|
    "feature_#{Faker::Internet.user_name}_#{n}"
  end

  sequence(:tagname) do |n|
    "1.#{n}.0"
  end

  factory :git_commit_hash, class: Hash do
    transient do
      branch 'master'
    end

    skip_create
    initialize_with { {} }
    after(:create) do |git_commit_hash, evaluator|
      git_commit_hash.merge!(message: generate(:commit_message),
                             branch: evaluator.branch,
                             update_ref: true)
    end
  end

  factory :git_commit_info, class: Hash do
    transient do
      branch 'master'
      content { generate(:content) }
      filepath { generate(:filepath) }
    end

    skip_create
    initialize_with { {} }

    after(:create) do |git_commit_info, evaluator|
      git_user = generate(:git_user)
      git_commit_info.merge!(file: {content: evaluator.content,
                                    path: evaluator.filepath},
                             author: git_user,
                             committer: git_user,
                             commit: create(:git_commit_hash,
                                            branch: evaluator.branch))
    end
  end

  factory :git, class: Gitlab::Git::Wrapper do
    transient do
      path { generate(:git_repository_path) }
    end
    skip_create
    initialize_with { Gitlab::Git::Wrapper.create(path) }
  end

  trait :with_commits do
    transient do
      commit_count 1
    end

    after(:create) do |git, evaluator|
      commit_files = (1..evaluator.commit_count).map { generate(:filepath) }
      commit_files.each do |filepath|
        git.create_file(create(:git_commit_info, filepath: filepath))
      end
    end
  end
end
