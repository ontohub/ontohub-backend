# frozen_string_literal: true

# Starts analysis jobs for all commits that were added since the old revision
# for each ref.
class RefsUpdater
  attr_reader :user, :repository, :git, :updated_refs
  def initialize(user, repository, updated_refs)
    @user = user
    @repository = RepositoryCompound.wrap(repository)
    @git = @repository.git
    @updated_refs = updated_refs
  end

  def call
    updated_refs.each do |info|
      analyze(info['ref'], info['before'], info['after'])
    end
  end

  protected

  def analyze(_ref, before, after)
    # This assumes that it was _not_ a force-push. It can _only_ be done because
    # force-pushes are prevented. With a force-push, we would need to find the
    # first common ancestor C of `before` and `after`, analyze all commits from
    # C onwards and delete `FileVersion`s after C leading to `before` that are
    # not part of another branch.
    log_options = {ref: "#{before}..#{after}",
                   unsafe_range: true,
                   only_commit_sha: true,
                   limit: nil}
    git.log(log_options).reverse_each do |commit_sha|
      process_new_commit(commit_sha)
      ProcessCommitJob.perform_later(repository.pk, commit_sha)
    end
  end

  def process_new_commit(commit_sha)
    git.diff_from_parent(commit_sha).each do |diff|
      create_file_version(commit_sha, diff.new_path) unless diff.deleted_file
    end
  end

  def create_file_version(commit_sha, file)
    Sequel::Model.db.transaction do
      action = Action.create(evaluation_state: 'not_yet_enqueued')
      FileVersion.create(action: action,
                         repository_id: repository.pk,
                         commit_sha: commit_sha,
                         path: file)
    end
  end
end
