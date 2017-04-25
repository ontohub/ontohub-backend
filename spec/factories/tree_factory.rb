# frozen_string_literal: true

FactoryGirl.define do
  factory :tree do
    transient do
      repository { create(:repository_compound) }
      commit_id { generate(:commit_sha) }
      path { generate(:filepath) }
      entries { [] }
    end
    skip_create
    initialize_with do
      Tree.new(commit_id: commit_id,
               entries: entries,
               path: path,
               repository: repository)
    end
  end
end
