# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Repository::PermissionsType do
  let!(:repository) { create :repository_compound }
  let!(:user) { create :user }

  subject { repository }

  let(:permissions_type) do
    OntohubBackendSchema.types['RepositoryPermissions']
  end

  before do
    subject.add_member(user, 'admin')
  end

  context 'role' do
    context 'user is a member of the repository' do
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

    context 'user is the owner of the repository' do
      let(:role_field) do
        OntohubBackendSchema.get_fields(permissions_type)['role']
      end

      it 'returns the role: admin' do
        role = role_field.resolve(
          subject,
          role_field.default_arguments,
          current_user: subject.owner
        )

        expect(role).to eq('admin')
      end
    end
  end
end
