# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::RepositoryType do
  let(:repository_type) { OntohubBackendSchema.types['Repository'] }
  let(:arguments) { {} }

  context 'visibility field' do
    let(:visibility_field) do
      OntohubBackendSchema.get_fields(repository_type)['visibility']
    end

    context 'public' do
      let(:repository) { create :repository, public_access: true }
      it 'returns public' do
        visibility = visibility_field.resolve(repository, arguments, {})
        expect(visibility).to eq('public')
      end
    end

    context 'private' do
      let(:repository) { create :repository, public_access: false }
      it 'returns private' do
        visibility = visibility_field.resolve(repository, arguments, {})
        expect(visibility).to eq('private')
      end
    end
  end

  let(:default_branch_field) do
    OntohubBackendSchema.get_fields(repository_type)['defaultBranch']
  end
  let(:branches_field) do
    OntohubBackendSchema.get_fields(repository_type)['branches']
  end
  let(:branch_field) do
    OntohubBackendSchema.get_fields(repository_type)['branch']
  end
  let(:tags_field) do
    OntohubBackendSchema.get_fields(repository_type)['tags']
  end
  let(:tag_field) { OntohubBackendSchema.get_fields(repository_type)['tag'] }
  let(:commit_field) do
    OntohubBackendSchema.get_fields(repository_type)['commit']
  end
  let(:diff_field) { OntohubBackendSchema.get_fields(repository_type)['diff'] }
  let(:log_field) { OntohubBackendSchema.get_fields(repository_type)['log'] }

  context 'empty repository' do
    let(:repository) { create :repository_compound }
    context 'defaultBranch field' do
      it 'returns nil' do
        default_branch = default_branch_field.resolve(repository, arguments, {})
        expect(default_branch).to be_nil
      end
    end

    context 'branches field' do
      it 'returns an empty list' do
        branches = branches_field.resolve(repository, arguments, {})
        expect(branches).to be_empty
      end
    end

    context 'branch field' do
      let(:arguments) { {'name' => 'master'} }

      it 'the branch does not exist, so it returns nil' do
        branch = branch_field.resolve(repository, arguments, {})
        expect(branch).to be(nil)
      end
    end

    context 'tags field' do
      it 'returns an empty list' do
        tags = tags_field.resolve(repository, arguments, {})
        expect(tags).to be_empty
      end
    end

    context 'tag field' do
      let(:arguments) { {'name' => 'v1.0'} }

      it 'the tag does not exist, so it returns nil' do
        tag = tag_field.resolve(repository, arguments, {})
        expect(tag).to be(nil)
      end
    end

    context 'commit field' do
      let(:arguments) { {'revision' => 'master'} }

      it 'the revision does not exist, so it returns nil' do
        commit = commit_field.resolve(repository, arguments, {})
        expect(commit).to be(nil)
      end
    end

    context 'diff field' do
      let(:arguments) do
        {'from' => 'master',
         'to' => 'master'}
      end
      let(:diff) { diff_field.resolve(repository, arguments, {}) }

      it 'at least one of the revisions does not exist, so it fails' do
        expect(diff).to be_a(GraphQL::ExecutionError)
      end

      it 'has the correct error message' do
        expect(diff.message).to match(/"to".*revspec 'master' not found/i)
      end
    end

    context 'log field' do
      let(:arguments) { {'revision' => 'master'} }
      let(:log) { log_field.resolve(repository, arguments, {}) }

      it 'is empty because there is no such revision' do
        expect(log).to be_empty
      end
    end
  end

  context 'non-empty repository' do
    let(:repository) { create :repository_compound, :not_empty }
    context 'defaultBranch field' do
      it 'returns master' do
        default_branch = default_branch_field.resolve(repository, arguments, {})
        expect(default_branch).to eq('master')
      end
    end

    context 'branches field' do
      it 'returns a list of branches' do
        branches = branches_field.resolve(repository, arguments, {})
        expect(branches).to eq(['master'])
      end
    end

    context 'branch field' do
      let(:name) { repository.git.default_branch }
      let(:arguments) { {'name' => name} }
      let(:branch) { branch_field.resolve(repository, arguments, {}) }

      context 'existing branch' do
        it 'returns the branch' do
          branch_info = {name: branch.name, target: branch.dereferenced_target}
          expect(branch_info).
            to eq(name: name, target: repository.git.commit(name))
        end
      end

      context 'inexistant branch' do
        let(:name) { 'inexistant' }
        it 'returns nil' do
          expect(branch).to be(nil)
        end
      end
    end

    context 'tags' do
      let(:message) { generate(:commit_message) }
      let(:tag_without_annotation) { 'tag_without_annotation' }
      let(:tag_with_annotation) { 'tag_with_annotation' }
      let!(:create_tags) do
        create(:tag, name: tag_without_annotation,
                     repository: repository,
                     revision: repository.git.default_branch)
        create(:tag, name: tag_with_annotation,
                     repository: repository,
                     revision: repository.git.default_branch,
                     message: message,
                     user: repository.owner)
      end

      context 'tags field' do
        it 'returns an empty list' do
          tags = tags_field.resolve(repository, arguments, {})
          expect(tags).
            to match_array([tag_without_annotation, tag_with_annotation])
        end
      end

      context 'tag field' do
        let(:arguments) { {'name' => name} }
        let(:tag) { tag_field.resolve(repository, arguments, {}) }

        context 'without annotation' do
          let(:name) { tag_without_annotation }

          it 'returns the tag' do
            tag_info = {name: tag.name,
                        target: tag.dereferenced_target,
                        annotation: tag.message}

            expect(tag_info).
              to eq(name: name,
                    target: repository.git.commit(name),
                    annotation: nil)
          end
        end

        context 'with annotation' do
          let(:name) { tag_with_annotation }

          it 'returns the tag' do
            tag_info = {name: tag.name,
                        target: tag.dereferenced_target,
                        annotation: tag.message}

            expect(tag_info).
              to eq(name: name,
                    target: repository.git.commit(name),
                    annotation: message.strip)
          end
        end

        context 'inexistant tag' do
          let(:name) { 'inexistant' }

          it 'returns nil' do
            expect(tag).to be(nil)
          end
        end
      end
    end

    context 'commit field' do
      let(:revision) { repository.git.default_branch }
      let(:arguments) { {'revision' => revision} }
      let(:commit) { commit_field.resolve(repository, arguments, {}) }

      context 'no revision' do
        let(:revision) { nil }

        it "finds the default branch's HEAD" do
          expect(commit).
            to eq(repository.git.commit(repository.git.default_branch))
        end
      end

      context 'existing revision' do
        it 'finds the commit' do
          expect(commit).to eq(repository.git.commit(revision))
        end
      end

      context 'inexistant revision' do
        let(:revision) { '0' * 40 }
        it 'finds the commit' do
          expect(commit).to be(nil)
        end
      end
    end

    context 'diff field' do
      before do
        2.times { create(:additional_file, repository: repository) }
      end

      let(:diff) { diff_field.resolve(repository, arguments, {}) }

      context 'over two commits' do
        let(:arguments) do
          {'from' => 'master~2',
           'to' => 'master'}
        end

        it 'is contains two diffs' do
          expect(diff.size).to eq(2)
        end
      end

      context 'with paths' do
        let(:paths) { repository.git.ls_files('master')[0..1] }
        let(:arguments) do
          {'from' => nil,
           'to' => 'master',
           'paths' => paths}
        end

        it 'is contains only diffs of the paths' do
          expect(diff.map(&:new_path)).to match_array(paths)
        end
      end

      context 'with an inexistant revision' do
        let(:revision) { 'inexistant' }
        let(:arguments) do
          {'from' => revision,
           'to' => 'master'}
        end

        it 'at least one of the revisions does not exist, so it fails' do
          expect(diff).to be_a(GraphQL::ExecutionError)
        end

        it 'has the correct error message' do
          expect(diff.message).
            to match(/"from".*revspec '#{revision}' not found/i)
        end
      end
    end

    context 'log field' do
      let(:revision) { repository.git.default_branch }
      let(:log) { log_field.resolve(repository, arguments, {}) }
      let(:files_a) { (0..1).map { |i| "dir_a/file_#{i}.txt" } }
      let(:files_b) { (0..1).map { |i| "dir_b/file_#{i}.txt" } }

      let!(:commits_a) do
        files_a.map do |path|
          create(:additional_file, repository: repository, path: path)
        end
      end

      let!(:commits_b) do
        files_b.map do |path|
          create(:additional_file, repository: repository, path: path)
        end
      end

      context 'given only the revision' do
        let(:arguments) { {'revision' => revision} }
        it 'lists all the commits' do
          expect(log.map(&:id)).
            to eq([*commits_b.reverse,
                   *commits_a.reverse,
                   repository.git.commit("#{commits_a.first}~").id])
        end
      end

      context 'given a path to a file' do
        let(:arguments) do
          {'revision' => revision,
           'path' => files_a.first}
        end
        it 'lists only the commits of the file' do
          expect(log.map(&:id)).to eq([commits_a.first])
        end
      end

      context 'given a path to a directory' do
        let(:arguments) do
          {'revision' => revision,
           'path' => File.dirname(files_a.first)}
        end
        it 'lists only the commits of the directory' do
          expect(log.map(&:id)).to eq(commits_a.reverse)
        end
      end

      context 'given a limit' do
        let(:arguments) do
          {'revision' => revision,
           'limit' => 2}
        end
        it 'lists all the commits up to the limit' do
          expect(log.map(&:id)).
            to eq([*commits_b.reverse])
        end
      end

      context 'given an offset' do
        let(:arguments) do
          {'revision' => revision,
           'skip' => 2}
        end
        it 'lists all the commits from the offset on' do
          expect(log.map(&:id)).
            to eq([*commits_a.reverse,
                   repository.git.commit("#{commits_a.first}~").id])
        end
      end
    end
  end

  context 'memberships field' do
    let(:repository) { create :repository, public_access: true }
    let(:memberships_field) do
      OntohubBackendSchema.get_fields(repository_type)['memberships']
    end

    before do
      21.times do
        user = create :user
        repository.add_member(user)
      end
      create :user
    end

    it 'returns only the memberships' do
      memberships = memberships_field.resolve(
        repository,
        memberships_field.default_arguments,
        {}
      )
      expect(memberships.count).to eq(20)
    end

    it 'limits the memberships list' do
      memberships = memberships_field.resolve(
        repository,
        memberships_field.default_arguments('limit' => 1),
        {}
      )
      expect(memberships.count).to eq(1)
    end

    it 'skips a number of memberships' do
      memberships = memberships_field.resolve(
        repository,
        memberships_field.default_arguments('skip' => 5),
        {}
      )
      expect(memberships.count).to eq(16)
    end
  end
  context 'urlMappings' do
    let(:repository) { create :repository }
    let(:url_mappings) { create_list(:url_mapping, 2, repository: repository) }
    let(:url_mappings_field) do
      OntohubBackendSchema.get_fields(repository_type)['urlMappings']
    end
    let(:resolved_url_mappings) do
      url_mappings_field.resolve(repository, {}, {})
    end
    it 'returns URL mappings' do
      expect(resolved_url_mappings).to eq(url_mappings)
    end
  end
end
