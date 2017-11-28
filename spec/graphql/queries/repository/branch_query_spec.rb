# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/branch query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $name: String!) {
      repository(id: $repositoryId) {
        branch(name: $name) {
          name
          target {
            id
          }
        }
      }
    }
    QUERY
  end

  let(:repository) do
    create(:repository_compound, :not_empty,
           public_access: false,
           owner: current_user)
  end
  let(:git) { repository.git }
  let!(:default_branch) { git.default_branch }

  let(:current_user) { create(:user) }
  let(:variables_base) { {'repositoryId' => repository.to_param} }

  it_behaves_like 'a GraphQL query', %w(repository branch) do
    let(:variables_existent) { variables_base.merge('name' => default_branch) }
    let(:variables_not_existent) { variables_base.merge('name' => 'bad') }

    let(:expectation_signed_in_existent) do
      branch_data = {
        'name' => default_branch,
        'target' => {'id' => git.commit(default_branch).id},
      }
      match('data' => {'repository' => {'branch' => branch_data}})
    end
    let(:expectation_signed_in_not_existent) do
      match('data' => {'repository' => {'branch' => nil}})
    end
    let(:expectation_not_signed_in_existent) do
      match('data' => {'repository' => nil})
    end
    let(:expectation_not_signed_in_not_existent) do
      expectation_not_signed_in_existent
    end
  end
end
