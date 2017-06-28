# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::OrganizationType do
  let!(:user1) { create :user }
  let!(:user2) { create :user }
  let!(:user3) { create :user }
  let!(:user4) { create :user }
  let!(:organization) { create :organization }

  before do
    organization.add_member(user1)
    organization.add_member(user2)
    organization.add_member(user3)
  end

  subject { organization }
  let(:organization_type) { OntohubBackendSchema.types['Organization'] }

  context 'members field' do
    let(:members_field) { organization_type.fields['members'] }
    it 'returns only the members' do
      members = members_field.resolve(organization, {}, {})
      expect(members.count).to be(3)
    end

    it 'limits the member list' do
      members = members_field.resolve(organization, {limit: 1}, {})
      expect(members.count).to be(1)
    end

    it 'skips a number of members' do
      members = members_field.resolve(organization, {skip: 1}, {})
      expect(members.count).to be(2)
    end
  end
end
