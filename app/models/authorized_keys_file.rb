# frozen_string_literal: true

# Class to rewrite the authorized_keys file
class AuthorizedKeysFile
  class << self
    def write
      keys = PublicKey.all.map do |key|
        "#{key.key.strip} #{key.name}"
      end

      Filelock(lock_file, timeout: 5) do
        path = Rails.root.join('tmp/data/authorized_keys')
        path.dirname.mkpath
        File.write(path, keys.join("\n"))
      end
    end

    private

    def lock_file
      File.join(Dir.tmpdir, 'ontohub_backend_authorized_keys.lock')
    end
  end
end
