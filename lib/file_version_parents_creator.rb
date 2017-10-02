# frozen_string_literal: true

# A service class that creates a FileVersionParent for every file that exists
# in the repository at the given commit. A run can take much time for large
# repositories because each file's git log is retrieved.
class FileVersionParentsCreator
  attr_reader :commit_sha, :git, :repository

  def initialize(repository_id, commit_sha)
    @commit_sha = commit_sha
    @repository = RepositoryCompound.find(id: repository_id)
    @git = @repository.git
  end

  def run
    git.ls_files(commit_sha).each do |filepath|
      target_sha = git.log(ref: commit_sha, path: filepath, limit: 1).first.id
      file_version = FileVersion.find(path: filepath, commit_sha: target_sha)
      FileVersionParent.create(queried_sha: commit_sha,
                               last_changed_file_version: file_version)
    end
  end
end
