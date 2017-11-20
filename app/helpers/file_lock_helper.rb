# frozen_string_literal: true

# Helper methods for file locks
module FileLockHelper
  extend module_function

  def exclusively(key, timeout: 1.minute)
    path =
      if Pathname.new(key).absolute?
        key
      else
        File.join(OntohubBackend::Application.config.lockdir, key)
      end
    FileUtils.mkdir_p(File.dirname(path))
    Filelock(path, timeout: timeout) { yield }
  end
end
