# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Organization::AddOrganizationMemberMutation do
  let!(:current_user) { create :user }
  let!(:organization) { create :organization }

  let!(:user) { create :user }

  before do
    organization.add_member(current_user, 'admin')
  end

  let(:context) { {current_user: current_user} }
  let(:variables) do
    {'user' => user.to_param,
     'organization' => organization.to_param,
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
    mutation AddOrganizationMember($organization: ID!, $user: ID!, $role: OrganizationRole!) {
      addOrganizationMember(organization: $organization, member: $user, role: $role) {
        organization {
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
          expect(subject['data']['addOrganizationMember']).to include(
            'member' => {'id' => user.to_param},
            'organization' => {'id' => organization.to_param},
            'role' => role
          )
        end
      end
    end
  end

  context 'Existing membership' do
    before do
      organization.add_member(user, 'read')
    end

    %w(admin write).each do |role|
      context "set role to: #{role}" do
        let(:role) { role }

        it 'returns the membership fields' do
          expect(subject['data']['addOrganizationMember']).to include(
            'member' => {'id' => user.to_param},
            'organization' => {'id' => organization.to_param},
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
      expect(subject['data']['addOrganizationMember']).to be(nil)
    end

    it 'returns an error' do
      expect(subject['errors']).
        to include(include('message' => "You're not authorized to do this"))
    end
  end
end
