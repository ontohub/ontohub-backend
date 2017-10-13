# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Organization::PermissionsType do
  let!(:organization) { create :organization }
  let!(:user) { create :user }

  subject { organization }

  let(:permissions_type) do
    OntohubBackendSchema.types['OrganizationPermissions']
  end

  before do
    subject.add_member(user, 'admin')
  end

  context 'role' do
    let(:role_field) do
      OntohubBackendSchema.get_fields(permissions_type)['role']
    end

    it 'returns the role' do
      role = role_field.resolve(
        subject,
        role_field.default_arguments,
        current_user: user
      )

      expect(role).to eq('admin')
    end
  end
end
