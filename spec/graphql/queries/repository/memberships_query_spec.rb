# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository/memberships query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($repositoryId: ID!, $role: RepositoryRole) {
      repository(id: $repositoryId) {
        memberships(role: $role) {
          member {
            id
          }
          repository {
            id
          }
          role
        }
      }
    }
    QUERY
  end

  let(:repository) do
    create(:repository_compound, :not_empty,
           commit_count: 2,
           public_access: false,
           owner: current_user)
  end
  let(:git) { repository.git }
  let(:user_admin) { create(:user) }
  let(:user_write) { create(:user) }
  let(:user_read) { create(:user) }
  let!(:membership_admin) do
    create(:repository_membership,
           repository: repository,
           member: user_admin,
           role: 'admin')
  end
  let!(:membership_write) do
    create(:repository_membership,
           repository: repository,
           member: user_write,
           role: 'write')
  end
  let!(:membership_read) do
    create(:repository_membership,
           repository: repository,
           member: user_read,
           role: 'read')
  end

  let(:current_user) { create(:user) }
  let(:variables_base) do
    {
      'repositoryId' => repository.to_param,
      'role' => nil,
    }
  end

  let(:variables_existent) { variables_base }
  let(:expectation_not_signed_in_existent) do
    match('data' => {'repository' => nil})
  end

  context 'with role argument' do
    %w(admin write read).each do |role_argument|
      context role_argument do
        let(:variables_existent) do
          variables_base.merge('role' => role_argument)
        end

        it_behaves_like 'a GraphQL query', %w(repository memberships), false do
          let(:expectation_signed_in_existent) do
            match('data' => {'repository' => {'memberships' => include(
              match('member' => {'id' =>
                                   send("user_#{role_argument}").to_param},
                    'repository' => {'id' => repository.to_param},
                    'role' => role_argument)
            )}})
          end
        end
      end
    end
  end

  context 'without role argument' do
    it_behaves_like 'a GraphQL query', %w(repository memberships), false do
      let(:expectation_signed_in_existent) do
        memberships = %w(admin write read).map do |role|
          match('member' => {'id' => send("user_#{role}").to_param},
                'repository' => {'id' => repository.to_param},
                'role' => role)
        end
        match('data' => {'repository' => {'memberships' =>
                                            match_array(memberships)}})
      end
    end
  end
end
