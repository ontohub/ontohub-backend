# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::UserType do
  let!(:user) { create :user }
  let!(:organization) { create :organization }
  let!(:repository) { create :repository }

  before do
    create :organization_membership, member: user,
                                     organization: organization,
                                     role: 'admin'
    create :repository_membership, member: user,
                                   repository: repository,
                                   role: 'admin'
    20.times do
      organization = create :organization
      organization.add_member(user)
      repository = create :repository
      repository.add_member(user)
    end
    create :organization
    create :repository
  end

  subject { user }
  let(:user_type) { OntohubBackendSchema.types['User'] }

  context 'organizationMemberships field' do
    let(:organization_memberships_field) do
      OntohubBackendSchema.get_fields(user_type)['organizationMemberships']
    end
    it 'returns only the memberships of the user' do
      organization_memberships = organization_memberships_field.resolve(
        user,
        organization_memberships_field.default_arguments,
        {}
      )
      expect(organization_memberships.count).to eq(20)
    end

    it 'limits the membership list' do
      organization_memberships = organization_memberships_field.resolve(
        user,
        organization_memberships_field.default_arguments('limit' => 1),
        {}
      )
      expect(organization_memberships.count).to eq(1)
    end

    it 'skips a number of memberships' do
      organization_memberships = organization_memberships_field.resolve(
        user,
        organization_memberships_field.default_arguments('skip' => 5),
        {}
      )
      expect(organization_memberships.count).to eq(16)
    end

    context 'filters by role' do
      let(:organization_memberships) do
        organization_memberships_field.resolve(
          user,
          organization_memberships_field.default_arguments('role' => role),
          {}
        )
      end

      context 'read' do
        let(:role) { 'read' }
        it 'returns the memberships with the role: read' do
          expect(organization_memberships.count).to eq(20)
        end
      end

      context 'admin' do
        let(:role) { 'admin' }
        it 'returns the memberships with the role: admin' do
          expect(organization_memberships.count).to eq(1)
        end
      end
    end
  end

  context 'repositoryMemberships field' do
    let(:repository_memberships_field) do
      OntohubBackendSchema.get_fields(user_type)['repositoryMemberships']
    end
    it 'returns only the memberships of the user' do
      repository_memberships = repository_memberships_field.resolve(
        user,
        repository_memberships_field.default_arguments,
        {}
      )
      expect(repository_memberships.count).to eq(20)
    end

    it 'limits the membership list' do
      repository_memberships = repository_memberships_field.resolve(
        user,
        repository_memberships_field.default_arguments('limit' => 1),
        {}
      )
      expect(repository_memberships.count).to eq(1)
    end

    it 'skips a number of memberships' do
      repository_memberships = repository_memberships_field.resolve(
        user,
        repository_memberships_field.default_arguments('skip' => 5),
        {}
      )
      expect(repository_memberships.count).to eq(16)
    end

    context 'filters by role' do
      let(:repository_memberships) do
        repository_memberships_field.resolve(
          user,
          repository_memberships_field.default_arguments('role' => role),
          {}
        )
      end

      context 'read' do
        let(:role) { 'read' }
        it 'returns the memberships with the role: read' do
          expect(repository_memberships.count).to eq(20)
        end
      end

      context 'admin' do
        let(:role) { 'admin' }
        it 'returns the memberships with the role: admin' do
          expect(repository_memberships.count).to eq(1)
        end
      end
    end
  end
end
