# frozen_string_literal: true

# Class to rewrite the authorized_keys file
class AuthorizedKeysFile
  LOCK_FILE = 'authorized_keys.lock'

  class << self
    def write
      keys = PublicKey.all.map do |key|
        "#{key.key.strip} #{key.name}"
      end

      FileLockHelper.exclusively(LOCK_FILE, timeout: 5.seconds) do
        path = Rails.root.join('tmp/data/authorized_keys')
        path.dirname.mkpath
        File.write(path, keys.join("\n"))
      end
    end
  end
end
