# frozen_string_literal: true

require 'ostruct'
require 'rails_helper'

RSpec.shared_examples 'number of entries' do
  it 'returns the correct number of entries' do
    expect(search_result['entries'].length).to eq(expected_num_entries)
    expect(search_result['count']['all']).to eq(expected_count_all)
    expect(search_result['count']['organizationalUnits']).
      to eq(expected_count_organizational_units)
    expect(search_result['count']['repositories']).
      to eq(expected_count_repositories)
  end
end

RSpec.describe 'Search query' do
  let(:user) { create :user }
  before do
    ::Index::UserIndex.purge
    ::Index::OrganizationIndex.purge
    ::Index::RepositoryIndex.purge
    
    ::Index::UserIndex.import(create :user, display_name: 'Ada')
    ::Index::UserIndex.import(create :user, display_name: 'Adc')
    ::Index::UserIndex.import(create :user, display_name: 'Bob')

    ::Index::OrganizationIndex.import(create :organization, display_name: 'Ada')
    ::Index::OrganizationIndex.import(create :organization, display_name: 'Bda Organization')
    ::Index::OrganizationIndex.import(create :organization, display_name: 'Abc_Organization')

    ::Index::RepositoryIndex.import(create :repository, name: 'Ada/repository', owner: user)
    ::Index::RepositoryIndex.import(create :repository, name: 'Bob/repository', owner: user)
    ::Index::RepositoryIndex.import(create :repository, name: 'Adc/repository', owner: user)
    ::Index::RepositoryIndex.import(create :repository, name: 'Bob/AdaRepository', owner: user)
  end

  let(:context) { {} }

  let(:result) do
    OntohubBackendSchema.execute(
      query_string,
      context: context,
      variables: variables
    )
  end

  let(:query_string) do
    <<-QUERY
    query Search($query: String!, $categories: [GlobalSearchCategory]) {
      search(query: $query) {
        global(categories: $categories) {
          count {
            all
            organizationalUnits
            repositories
          }
          entries {
            entry {
              __typename
              ... on User {
                id
                displayName
              }
              ... on Organization {
                id
                displayName
              }
              ... on Repository {
                id
                description
              }
            }
            ranking
          }
        }
      }
    }
    QUERY
  end

  let(:search_result) { result['data']['search'][scope] }

  context 'with global scope' do
    let(:scope) { 'global' }
    context 'no categories' do
      let(:variables) { {'query' => 'Ada'} }
      let(:expected_num_entries) { 6 }
      let(:expected_count_all) { 6 }
      let(:expected_count_organizational_units) { 4 }
      let(:expected_count_repositories) { 2 }

      include_examples 'number of entries'

      it 'returns the repositories' do
        repositories = search_result['entries'].select do |e|
          e['entry']['__typename'] == 'Repository'
        end
        expect(repositories.length).to eq(expected_count_repositories)
      end

      it 'returns the organizational units' do
        organizational_units = search_result['entries'].select do |e|
          %w(User Organization).include?(e['entry']['__typename'])
        end
        expect(organizational_units.length).to eq(expected_count_organizational_units)
      end
    end

    context 'category: all' do
      let(:variables) do
        {'query' => 'Ada', 'categories' => %w(repositories organizationalUnits)}
      end
      let(:expected_num_entries) { 6 }
      let(:expected_count_all) { 6 }
      let(:expected_count_organizational_units) { 4 }
      let(:expected_count_repositories) { 2 }

      include_examples 'number of entries'

      it 'returns the repositories' do
        repositories = search_result['entries'].select do |e|
          e['entry']['__typename'] == 'Repository'
        end
        expect(repositories.length).to eq(expected_count_repositories)
      end

      it 'returns the organizational units' do
        organizational_units = search_result['entries'].select do |e|
          %w(User Organization).include?(e['entry']['__typename'])
        end
        expect(organizational_units.length).to eq(expected_count_organizational_units)
      end
    end

    context 'category: repositories' do
      let(:variables) { {'query' => 'Ada', 'categories' => %w(repositories)} }
      let(:expected_num_entries) { 2 }
      let(:expected_count_all) { 2 }
      let(:expected_count_organizational_units) { 0 }
      let(:expected_count_repositories) { 2 }

      include_examples 'number of entries'

      it 'returns the repositories' do
        repositories = search_result['entries'].select do |e|
          e['entry']['__typename'] == 'Repository'
        end
        expect(repositories.length).to eq(expected_count_repositories)
      end
    end

    context 'category: organizationalUnits' do
      let(:variables) do
        {'query' => 'Ada', 'categories' => %w(organizationalUnits)}
      end
      let(:expected_num_entries) { 4 }
      let(:expected_count_all) { 4 }
      let(:expected_count_organizational_units) { 4 }
      let(:expected_count_repositories) { 0 }

      include_examples 'number of entries'
      it 'returns the organizational units' do
        organizational_units = search_result['entries'].select do |e|
          %w(User Organization).include?(e['entry']['__typename'])
        end
        expect(organizational_units.length).to eq(expected_count_organizational_units)
      end
    end
  end
end
