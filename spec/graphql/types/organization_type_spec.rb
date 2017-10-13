# frozen_string_literal: true

require 'rails_helper'

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

  context 'memberships field' do
    let(:memberships_field) do
      OntohubBackendSchema.get_fields(organization_type)['memberships']
    end
    it 'returns only the memberships' do
      memberships = memberships_field.resolve(
        organization,
        memberships_field.default_arguments,
        {}
      )
      expect(memberships.count).to eq(20)
    end

    it 'limits the memberships list' do
      memberships = memberships_field.resolve(
        organization,
        memberships_field.default_arguments('limit' => 1),
        {}
      )
      expect(memberships.count).to eq(1)
    end

    it 'skips a number of memberships' do
      memberships = memberships_field.resolve(
        organization,
        memberships_field.default_arguments('skip' => 5),
        {}
      )
      expect(memberships.count).to eq(16)
    end
  end
end
