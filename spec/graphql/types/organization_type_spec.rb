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
    let(:members_field) do
      OntohubBackendSchema.get_fields(organization_type)['members']
    end
    it 'returns only the members' do
      members = members_field.resolve(
        organization,
        members_field.default_arguments,
        {}
      )
      expect(members.count).to eq(20)
    end

    it 'limits the member list' do
      members = members_field.resolve(
        organization,
        members_field.default_arguments('limit' => 1),
        {}
      )
      expect(members.count).to eq(1)
    end

    it 'skips a number of members' do
      members = members_field.resolve(
        organization,
        members_field.default_arguments('skip' => 5),
        {}
      )
      expect(members.count).to eq(16)
    end
  end
end
