# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'repository query' do
  let(:context) { {} }

  let(:query_string) do
    <<-QUERY
    query ($id: ID!) {
      repository(id: $id) {
        branches
        contentType
        defaultBranch
        description
        id
        name
        owner {
          id
        }
        permissions {
          role
        }
        tags
        visibility
      }
    }
    QUERY
  end

  let(:repository_db) { create(:repository, public_access: access == 'public') }
  let!(:repository) do
    create(:repository_compound, :not_empty, repository: repository_db)
  end
  let!(:tags) { create_list(:tag, 2, repository: repository) }
  let(:repository_data) do
    {
      'branches' => match_array(repository.git.branch_names),
      'contentType' => repository.content_type,
      'defaultBranch' => repository.git.default_branch,
      'description' => repository.description,
      'id' => repository.to_param,
      'name' => repository.name,
      'owner' => {'id' => repository.owner.to_param},
      'tags' => match_array(tags.map(&:name)),
      'visibility' => access,
    }
  end

  let(:current_user) { create(:user) }

  let(:variables_existent) { {'id' => repository.to_param} }
  let(:variables_not_existent) { {'id' => "bad-#{repository.to_param}"} }

  %w(read write admin).each do |permission|
    context "with #{permission} permissions" do
      let(:permissions) { {'role' => permission} }

      before do
        repository.add_member(current_user, permission)
      end

      let(:expectation) do
        repository_data.merge('permissions' => {'role' => permission})
      end

      context 'with public access' do
        let(:access) { 'public' }

        it_behaves_like 'a GraphQL query', 'repository' do
          let(:expectation_signed_in_existent) do
            match('data' => {'repository' => include(
              expectation.merge('permissions' => permissions)
            )})
          end
          let(:expectation_signed_in_not_existent) do
            match('data' => {'repository' => nil})
          end
          let(:expectation_not_signed_in_existent) do
            match('data' => {'repository' => include(
              expectation.merge('permissions' => nil)
            )})
          end
          let(:expectation_not_signed_in_not_existent) do
            expectation_signed_in_not_existent
          end
        end
      end

      context 'with private access' do
        let(:access) { 'private' }

        it_behaves_like 'a GraphQL query', 'repository' do
          let(:expectation_signed_in_existent) do
            match('data' => {'repository' => include(
              expectation.merge('permissions' => permissions)
            )})
          end
          let(:expectation_signed_in_not_existent) do
            match('data' => {'repository' => nil})
          end
          let(:expectation_not_signed_in_existent) do
            expectation_signed_in_not_existent
          end
          let(:expectation_not_signed_in_not_existent) do
            expectation_signed_in_not_existent
          end
        end
      end
    end
  end

  context 'without permissions' do
    context 'with public access' do
      let(:access) { 'public' }
      let(:expectation) do
        repository_data.merge('permissions' => nil)
      end

      it_behaves_like 'a GraphQL query', 'repository' do
        let(:expectation_signed_in_existent) do
          match('data' => {'repository' => include(expectation)})
        end
        let(:expectation_signed_in_not_existent) do
          match('data' => {'repository' => nil})
        end
        let(:expectation_not_signed_in_existent) do
          match('data' => {'repository' => include(expectation)})
        end
        let(:expectation_not_signed_in_not_existent) do
          expectation_signed_in_not_existent
        end
      end
    end

    context 'with private access' do
      let(:access) { 'private' }

      it_behaves_like 'a GraphQL query', 'repository' do
        let(:expectation_signed_in_existent) do
          expectation_signed_in_not_existent
        end
        let(:expectation_signed_in_not_existent) do
          match('data' => {'repository' => nil})
        end
        let(:expectation_not_signed_in_existent) do
          expectation_signed_in_not_existent
        end
        let(:expectation_not_signed_in_not_existent) do
          expectation_signed_in_not_existent
        end
      end
    end
  end
end
