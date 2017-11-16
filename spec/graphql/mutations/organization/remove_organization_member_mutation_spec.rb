# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Organization::RemoveOrganizationMemberMutation do
  let!(:current_user) { create :user }
  let!(:organization) { create :organization }

  let!(:user) { create :user }

  before do
    organization.add_member(current_user, 'admin')
    organization.add_member(user, 'write')
  end

  let(:context) { {current_user: current_user} }
  let(:variables) do
    {'user' => user.to_param,
     'organization' => organization.to_param}
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
    mutation RemoveOrganizationMember($organization: ID!, $user: ID!) {
      removeOrganizationMember(organization: $organization, member: $user)
    }
    QUERY
  end

  subject { result }

  context 'Successful removal' do
    it 'returns true' do
      expect(subject).to match('data' => {'removeOrganizationMember' => true})
    end
  end

  context 'User does not exist' do
    let(:variables) do
      {'user' => "bad-#{user.to_param}",
       'organization' => organization.to_param}
    end

    it 'returns false' do
      expect(subject).to match('data' => {'removeOrganizationMember' => false})
    end
  end

  context 'User is not a member' do
    let(:variables) do
      {'user' => create(:user).to_param,
       'organization' => organization.to_param}
    end

    it 'returns false' do
      expect(subject).to match('data' => {'removeOrganizationMember' => false})
    end
  end

  context 'Not signed in' do
    let(:context) { {} }

    it 'returns an error' do
      expect(subject.to_h).
        to match('data' => {'removeOrganizationMember' => nil},
                 'errors' =>
                   include(include('message' =>
                                     "You're not authorized to do this")))
    end
  end
end
