# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'a directory entry in GraphQL' do
  let(:repository) { create(:repository_compound) }
  let(:revision) { repository.git.default_branch }
  let(:commit) { repository.git.commit(revision) }
  let(:resolved_field) { field.resolve(subject, arguments, {}) }

  context 'log field' do
    let(:field) { type.get_field('log') }

    let(:directory) { 'dir' }
    let(:file) { "#{directory}/file.txt" }
    let(:files_a) { (0..1).map { |i| "#{directory}/file_#{i}.txt" } }
    let(:files_b) { (0..1).map { |i| "other-#{directory}/file_#{i}.txt" } }

    let!(:commits_file) do
      (0..5).map do |i|
        create(:additional_commit,
               repository: repository,
               files: [{action: i == 0 ? 'create' : 'update',
                        path: file,
                        content: generate(:content),
                        encoding: 'plain'}])
      end
    end

    let!(:commits_a) do
      files_a.map do |filepath|
        create(:additional_file, repository: repository, path: filepath)
      end
    end

    let!(:commits_b) do
      files_b.map do |filepath|
        create(:additional_file, repository: repository, path: filepath)
      end
    end

    context 'without restrictions' do
      let(:arguments) { {} }
      it 'lists all the commits up to the limit' do
        expected_commits
        resolved_field
        expect(resolved_field.map(&:id)).to eq(expected_commits.reverse)
      end
    end

    context 'given a limit' do
      let(:arguments) { {'limit' => 2} }
      it 'lists all the commits up to the limit' do
        expect(resolved_field.map(&:id)).to eq(expected_commits.reverse[0..1])
      end
    end

    context 'given an offset' do
      let(:arguments) { {'skip' => 2} }
      it 'lists all the commits from the offset on' do
        expect(resolved_field.map(&:id)).to eq(expected_commits.reverse[2..-1])
      end
    end
  end
end

RSpec.describe Types::Git::FileType do
  let(:type) { OntohubBackendSchema.types['File'] }
  let(:path) { file }
  subject { GitFile.new(commit, path) }
  let(:expected_commits) { commits_file }
  it_behaves_like 'a directory entry in GraphQL'
end

RSpec.describe Types::Git::DirectoryType do
  let(:type) { OntohubBackendSchema.types['Directory'] }
  let(:path) { directory }
  subject do
    index =
      repository.git.tree(commit.id, path).map do |gitlab_tree|
        if gitlab_tree.type == :tree
          GitDirectory.new(commit, gitlab_tree.name, gitlab_tree.path)
        else
          GitFile.new(commit, gitlab_tree.path, name: gitlab_tree.name)
        end
      end
    index.sort do |a, b|
      comparison = a.kind <=> b.kind
      comparison.zero? ? (a.name <=> b.name) : comparison
    end
  end
  let(:expected_commits) { [*commits_file, *commits_a] }
  it_behaves_like 'a directory entry in GraphQL'
end
