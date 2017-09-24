# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'an owner of repositories' do
  before do
    21.times do
      create(:repository_compound, :not_empty, owner: organizational_unit)
    end
  end

  it 'returns only the repositories owned by the organizational unit' do
    repositories = repositories_field.resolve(
      organizational_unit,
      repositories_field.default_arguments,
      {}
    )
    expect(repositories.count).to eq(20)
  end

  it 'limits the repository list' do
    repositories = repositories_field.resolve(
      organizational_unit,
      repositories_field.default_arguments('limit' => 1),
      {}
    )
    expect(repositories.count).to eq(1)
  end

  it 'skips a number of repositories' do
    repositories = repositories_field.resolve(
      organizational_unit,
      repositories_field.default_arguments('skip' => 5),
      {}
    )
    expect(repositories.count).to eq(16)
  end

  it 'returns wrapped repositories' do
    repositories = repositories_field.resolve(
      organizational_unit,
      repositories_field.default_arguments,
      {}
    )
    expect(repositories.all? { |r| r.is_a?(RepositoryCompound) }).to be_truthy
  end
end

RSpec.describe Types::OrganizationalUnitType do
  let(:repositories_field) do
    OntohubBackendSchema.get_fields(organizational_unit_type)['repositories']
  end

  context User do
    let(:organizational_unit_type) { OntohubBackendSchema.types['User'] }
    let(:organizational_unit) { create :user }
    it_behaves_like 'an owner of repositories'
  end

  context Organization do
    let(:organizational_unit_type) do
      OntohubBackendSchema.types['Organization']
    end
    let(:organizational_unit) { create :organization }
    it_behaves_like 'an owner of repositories'
  end
end
