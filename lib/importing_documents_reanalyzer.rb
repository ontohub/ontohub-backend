# frozen_string_literal: true

# If a Document that is imported by another Document is changed, the importing
# one needs to be analysed again, while importing the newer revision of the
# imported one.
# It takes long in a big repository because the git log needs to be walked to
# the end.
class ImportingDocumentsReanalyzer
  attr_reader :commit_sha, :git, :file_path, :file_version, :repository

  def initialize(file_version_id)
    @file_version = FileVersion.first!(id: file_version_id)
    @file_path = file_version.path
    @commit_sha = file_version.commit_sha
    @repository = RepositoryCompound.first!(id: file_version.repository_id)
    @git = repository.git
  end

  def call
    return :requeue if previous_versions_still_processing?
    process
    :done
  end

  protected

  def previous_versions_still_processing?
    # TODO: This method can be optimized:
    # Find the newest commit C that is finished processing for sure.
    # instead of `ref: commit_sha`, use `ref: "#{C}..#{commit_sha}"
    # for the git log.
    unfinished_shas =
      FileVersion.
        where(evaluation_state: %w(not_yet_enqueued enqueued processing),
              repository_id: file_version.repository_id).
        map(:commit_sha)
    # Go all the way back to the root commit (this can be optimized)
    git.log(ref: commit_sha, limit: 0, only_commit_sha: true).any? do |log_sha|
      unfinished_shas.include?(log_sha)
    end
  end

  def process
    return if Document.where(file_version_id: file_version.id).empty?
    previous_revision = find_previous_revision
    return if previous_revision.nil?

    previous_revision.imported_by.each do |importer|
      Sequel::Model.db.transaction do
        next if already_analyzed?(importer)
        reanalyze_importer(importer)
      end
    end
  end

  def find_previous_revision
    target_sha = git.log(ref: commit_sha, path: file_path, limit: 2)[1]&.id
    return nil if target_sha.nil?

    previous_file_version = FileVersion.find(path: file_path,
                                             commit_sha: target_sha)
    Document.first(file_version_id: previous_file_version&.id)
  end

  def already_analyzed?(document)
    !FileVersion.where(repository_id: repository.id,
                       commit_sha: commit_sha,
                       path: document.file_version.path).empty?
  end

  def reanalyze_importer(importer)
    new_file_version =
      FileVersion.create(repository_id: repository.id,
                         commit_sha: commit_sha,
                         path: importer.file_version.path)
    modify_file_version_parents(importer, new_file_version)

    request_collection =
      HetsAgent::ReanalysisRequestCollection.new(new_file_version)
    HetsAgent::Invoker.new(request_collection).call
  end

  # This takes long in a big repository
  def modify_file_version_parents(document, new_file_version)
    git.log(ref: range_until_next_change(new_file_version),
            unsafe_range: true,
            limit: 0).each do |commit|
      FileVersionParent.
        where(last_changed_file_version_id: document.file_version.id,
              queried_sha: commit.id).
        update(last_changed_file_version_id: new_file_version.id)
    end
  end

  # This does not include the commit of the next change
  def range_until_next_change(new_file_version)
    first_newer_sha = next_changing_commit(new_file_version)
    end_revision = first_newer_sha.nil? ? '' : "#{first_newer_sha}~1"

    # Using the parent-commit-operator "~1" is safe because we inspect an
    # updated revision of the file. Hence, a previous revision must exist.
    "#{new_file_version.commit_sha}~1..#{end_revision}"
  end

  # This takes long in a big repository
  def next_changing_commit(importer_file_version)
    git.log(ref: "#{importer_file_version.commit_sha}..",
            path: importer_file_version.path,
            unsafe_range: true,
            limit: 0)[-1]&.id
  end
end
