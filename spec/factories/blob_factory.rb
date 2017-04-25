# frozen_string_literal: true

FactoryGirl.define do
  factory :blob do
    transient do
      repository { create(:repository_compound) }
      path { generate(:filepath) }
      branch { 'master' }
      content { 'content' }
      encoding { 'plain' }
      commit_message { generate(:commit_message) }
      user { create(:user) }
    end
    skip_create
    initialize_with do
      Blob.new(repository: repository,
               branch: branch,
               path: path,
               content: content,
               encoding: encoding,
               commit_message: commit_message,
               user: user)
    end
  end
end
