# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Version query' do
  before do
    stub_const('Version::VERSION', '0.0.0-12-gabcdefg')
  end

  let(:context) { {} }
  let(:variables) { {} }

  let(:result) do
    res = OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
    puts res if res['errors']
    res
  end

  let(:query_string) do
    <<-QUERY
    {
      version {
        full
        commit
        tag
        commitsSinceTag
      }
    }
    QUERY
  end

  it 'returns the current version' do
    version = result['data']['version']
    expect(version).to include(
      'full' => '0.0.0-12-gabcdefg',
      'tag' => '0.0.0',
      'commit' => 'abcdefg',
      'commitsSinceTag' => 12
    )
  end
end
