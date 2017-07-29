# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::RepositoryType do
  let(:repository_type) { OntohubBackendSchema.types['Repository'] }
  let(:arguments) { {} }

  context 'visibility field' do
    let(:visibility_field) { repository_type.fields['visibility'] }

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

  let(:default_branch_field) { repository_type.fields['defaultBranch'] }
  let(:branches_field) { repository_type.fields['branches'] }
  let(:branch_field) { repository_type.fields['branch'] }
  let(:tags_field) { repository_type.fields['tags'] }
  let(:tag_field) { repository_type.fields['tag'] }
  let(:commit_field) { repository_type.fields['commit'] }
  let(:diff_field) { repository_type.fields['diff'] }

  context 'empty repository' do
    let(:repository) { create :repository_compound, :empty_git }
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
        expect(diff.message).to match(/"to".*Revspec 'master' not found./)
      end
    end
  end

  context 'non-empty repository' do
    let(:repository) { create :repository_compound }
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
        repository.git.create_tag(tag_without_annotation,
                                  repository.git.default_branch)
        repository.git.create_tag(tag_with_annotation,
                                  repository.git.default_branch,
                                  message: message,
                                  tagger: generate(:git_user))
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
            to match(/"from".*Revspec '#{revision}' not found./)
        end
      end
    end
  end
end
