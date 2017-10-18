# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Organization::PermissionsType do
  let!(:organization) { create :organization }
  let!(:user) { create :user }

  subject { organization }

  let(:permissions_type) do
    OntohubBackendSchema.types['OrganizationPermissions']
  end

  let(:role_field) do
    OntohubBackendSchema.get_fields(permissions_type)['role']
  end

  %w(admin read write).each do |role|
    context "role: #{role}" do
      before do
        subject.add_member(user, role)
      end

      it 'returns the role' do
        resolved_role = role_field.resolve(
          subject,
          role_field.default_arguments,
          current_user: user
        )

        expect(resolved_role).to eq(role)
      end
    end
  end
end
