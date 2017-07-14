# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::UserType do
  let!(:user) { create :user }

  before do
    21.times do
      organization = create :organization
      organization.add_member(user)
    end
    create :organization
  end

  subject { user }
  let(:user_type) { OntohubBackendSchema.types['User'] }

  context 'members field' do
    let(:organizations_field) { user_type.fields['organizations'] }
    it 'returns only the organizations to user is a member in' do
      organizations = organizations_field.resolve(user, {}, {})
      expect(organizations.count).to be(20)
    end

    it 'limits the organization list' do
      organizations = organizations_field.resolve(user, {limit: 1}, {})
      expect(organizations.count).to be(1)
    end

    it 'skips a number of organizations' do
      organizations = organizations_field.resolve(user, {skip: 5}, {})
      expect(organizations.count).to be(16)
    end
  end
end
