# frozen_string_literal: true

FactoryGirl.define do
  factory :tree_entry do
    transient do
      gitlab_tree { create(:gitlab_tree) }
      repository { create(:repository) }
      commit_id { generate(:commit_sha) }
    end
    skip_create
    initialize_with do
      params = {path: generate(:filepath),
                type: :blobs}
      params[:name] = File.basename(params[:path])
      TreeEntry.new(nil, nil, nil, params)
    end
  end
end
