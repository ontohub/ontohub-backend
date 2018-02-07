# frozen_string_literal: true

# Class to rewrite the authorized_keys file
class AuthorizedKeysFile
  AUTHORIZED_KEYS_FILE =
    Rails.root.join("tmp/#{Rails.env}/data/authorized_keys")
  LOCK_FILE = 'authorized_keys.lock'
  SSH_FLAGS = ',no-port-forwarding,no-x11-forwarding,no-agent-forwarding,no-pty'

  class << self
    def write
      keys = PublicKey.all.map do |key|
        command = "#{Settings.git_shell.path} #{key.id}"
        %(command="#{command}"#{SSH_FLAGS} #{key.key.strip} #{key.name})
      end

      FileLockHelper.exclusively(LOCK_FILE, timeout: 5.seconds) do
        AUTHORIZED_KEYS_FILE.dirname.mkpath
        File.write(AUTHORIZED_KEYS_FILE, keys.join("\n"))
      end
    end
  end
end
