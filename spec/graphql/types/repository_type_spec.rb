# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::RepositoryType do
  let(:repository_type) { OntohubBackendSchema.types['Repository'] }

  context 'visibility field' do
    let(:visibility_field) { repository_type.fields['visibility'] }

    context 'public' do
      let(:repository) { create :repository, public_access: true }
      it 'returns public' do
        visibility = visibility_field.resolve(repository, {}, {})
        expect(visibility).to eq('public')
      end
    end

    context 'private' do
      let(:repository) { create :repository, public_access: false }
      it 'returns private' do
        visibility = visibility_field.resolve(repository, {}, {})
        expect(visibility).to eq('private')
      end
    end
  end

  let(:default_branch_field) { repository_type.fields['defaultBranch'] }
  let(:branches_field) { repository_type.fields['branches'] }

  context 'empty repository' do
    let(:repository) { create :repository_compound, :empty_git }
    context 'defaultBranch field' do
      it 'returns nil' do
        default_branch = default_branch_field.resolve(repository, {}, {})
        expect(default_branch).to be_nil
      end
    end

    context 'branches field' do
      it 'returns an empty list' do
        branches = branches_field.resolve(repository, {}, {})
        expect(branches).to be_empty
      end
    end
  end

  context 'non-empty repository' do
    let(:repository) { create :repository_compound }
    context 'defaultBranch field' do
      it 'returns master' do
        default_branch = default_branch_field.resolve(repository, {}, {})
        expect(default_branch).to eq('master')
      end
    end
    context 'branches field' do
      it 'returns a list of branches' do
        branches = branches_field.resolve(repository, {}, {})
        expect(branches).to eq(['master'])
      end
    end
  end
end
