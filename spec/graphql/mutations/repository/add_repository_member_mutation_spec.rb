# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Repository::AddRepositoryMemberMutation do
  let!(:current_user) { create :user }
  let!(:repository) { create :repository_compound, owner: current_user }

  let!(:user) { create :user }

  let(:context) { {current_user: current_user} }
  let(:variables) do
    {'user' => user.to_param,
     'repository' => repository.to_param,
     'role' => role}
  end

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    mutation AddRepositoryMember($repository: ID!, $user: ID!, $role: RepositoryRole!) {
      addRepositoryMember(repository: $repository, member: $user, role: $role) {
        repository {
          id
        }
        member {
          id
        }
        role
      }
    }
    QUERY
  end

  subject { result }

  context 'Successful addition' do
    %w(admin read write).each do |role|
      context "with role: #{role}" do
        let(:role) { role }

        it 'returns the membership fields' do
          expect(subject['data']['addRepositoryMember']).to include(
            'member' => {'id' => user.to_param},
            'repository' => {'id' => repository.to_param},
            'role' => role
          )
        end
      end
    end
  end

  context 'Existing membership' do
    before do
      repository.add_member(user, 'read')
    end

    %w(admin write).each do |role|
      context "set role to: #{role}" do
        let(:role) { role }

        it 'returns the membership fields' do
          expect(subject['data']['addRepositoryMember']).to include(
            'member' => {'id' => user.to_param},
            'repository' => {'id' => repository.to_param},
            'role' => role
          )
        end
      end
    end
  end

  context 'Not signed in' do
    let(:context) { {} }
    let(:role) { 'read' }

    it 'returns no data' do
      expect(subject['data']['addRepositoryMember']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => "You're not authorized to do this"))
    end
  end
end
