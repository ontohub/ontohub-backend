# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::UserType do
  let!(:user) { create :user }
  let!(:organization1) { create :organization }
  let!(:organization2) { create :organization }
  let!(:organization3) { create :organization }
  let!(:organization4) { create :organization }
  let!(:repository1) { create(:repository_compound, owner: user) }
  let!(:repository2) { create(:repository_compound, owner: user) }
  let!(:repository3) { create(:repository_compound, owner: user) }
  let!(:repository4) { create(:repository_compound) }

  before do
    organization1.add_member(user)
    organization2.add_member(user)
    organization3.add_member(user)
  end

  subject { user }
  let(:user_type) { OntohubBackendSchema.types['User'] }

  context 'members field' do
    let(:organizations_field) { user_type.fields['organizations'] }
    it 'returns only the organizations to user is a member in' do
      organizations = organizations_field.resolve(user, {}, {})
      expect(organizations.count).to be(3)
    end

    it 'limits the organization list' do
      organizations = organizations_field.resolve(user, {limit: 1}, {})
      expect(organizations.count).to be(1)
    end

    it 'skips a number of organizations' do
      organizations = organizations_field.resolve(user, {skip: 1}, {})
      expect(organizations.count).to be(2)
    end
  end

  context 'repositories field' do
    let(:repositories_field) { user_type.fields['repositories'] }
    it 'returns only the repositories owned by the user' do
      repositories = repositories_field.resolve(user, {}, {})
      expect(repositories.count).to be(3)
    end

    it 'limits the repository list' do
      repositories = repositories_field.resolve(user, {limit: 1}, {})
      expect(repositories.count).to be(1)
    end

    it 'skips a number of repositories' do
      repositories = repositories_field.resolve(user, {skip: 1}, {})
      expect(repositories.count).to be(2)
    end
  end
end
