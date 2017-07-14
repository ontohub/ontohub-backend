# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::OrganizationType do
  let!(:organization) { create :organization }

  before do
    21.times do
      user = create :user
      organization.add_member(user)
    end
    create :user
  end

  subject { organization }
  let(:organization_type) { OntohubBackendSchema.types['Organization'] }

  context 'members field' do
    let(:members_field) { organization_type.fields['members'] }
    it 'returns only the members' do
      members = members_field.resolve(organization, {}, {})
      expect(members.count).to be(20)
    end

    it 'limits the member list' do
      members = members_field.resolve(organization, {limit: 1}, {})
      expect(members.count).to be(1)
    end

    it 'skips a number of members' do
      members = members_field.resolve(organization, {skip: 5}, {})
      expect(members.count).to be(16)
    end
  end
end
