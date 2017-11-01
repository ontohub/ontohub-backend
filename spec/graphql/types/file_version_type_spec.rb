# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::FileVersionType do
  let(:repository) { create(:repository_compound, :not_empty) }
  let(:commit) { repository.git.commit(repository.git.default_branch) }
  let(:file_version) { FileVersion.first(commit_sha: commit.id) }

  let(:type) { OntohubBackendSchema.types['FileVersion'] }
  let(:arguments) { {} }

  context 'commit field' do
    let(:field) { OntohubBackendSchema.get_fields(type)['commit'] }

    it 'returns the commit' do
      resolved_field = field.resolve(file_version, arguments, {})
      expect(resolved_field).to eq(commit)
    end
  end
end
