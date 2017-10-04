# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::UserType do
  let!(:user) { create :user }
  let!(:organization) { create :organization }

  before do
    create :organization_membership, member: user,
                                     organization: organization,
                                     role: 'admin'
    20.times do
      organization = create :organization
      organization.add_member(user)
    end
    create :organization
  end

  subject { user }
  let(:user_type) { OntohubBackendSchema.types['User'] }

  context 'organizations field' do
    let(:organizations_field) do
      OntohubBackendSchema.get_fields(user_type)['organizations']
    end
    it 'returns only the organizations to user is a member in' do
      organizations = organizations_field.resolve(
        user,
        organizations_field.default_arguments,
        {}
      )
      expect(organizations.count).to eq(20)
    end

    it 'limits the organization list' do
      organizations = organizations_field.resolve(
        user,
        organizations_field.default_arguments('limit' => 1),
        {}
      )
      expect(organizations.count).to eq(1)
    end

    it 'skips a number of organizations' do
      organizations = organizations_field.resolve(
        user,
        organizations_field.default_arguments('skip' => 5),
        {}
      )
      expect(organizations.count).to eq(16)
    end

    context 'filters by role' do
      let(:organizations) do
        organizations_field.resolve(
          user,
          organizations_field.default_arguments('role' => role),
          {}
        )
      end

      context 'read' do
        let(:role) { 'read' }
        it 'returns the organizations with the role: read' do
          expect(organizations.count).to eq(20)
        end
      end

      context 'admin' do
        let(:role) { 'admin' }
        it 'returns the organizations with the role: admin' do
          expect(organizations.count).to eq(1)
        end
      end
    end
  end
end
