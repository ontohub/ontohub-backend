# frozen_string_literal: true

# Class to rewrite the authorized_keys file
class AuthorizedKeysFile
  AUTHORIZED_KEYS_FILE = Settings.data_directory.join('ssh/authorized_keys')
  LOCK_FILE = 'authorized_keys.lock'
  SSH_FLAGS = ',no-port-forwarding,no-x11-forwarding,no-agent-forwarding,no-pty'

  class << self
    def write
      authorized_keys_lines = PublicKey.all.map do |key|
        authorized_keys_line(key)
      end

      FileLockHelper.exclusively(LOCK_FILE, timeout: 5.seconds) do
        AUTHORIZED_KEYS_FILE.dirname.mkpath
        File.write(AUTHORIZED_KEYS_FILE, authorized_keys_lines.join("\n"))
      end

      copy_authorized_keys_to_git_user
    end

    protected

    def authorized_keys_line(key)
      command = "#{Settings.git_shell.path} #{key.id}"
      %(command="#{command}"#{SSH_FLAGS} #{key.key.strip} #{key.name})
    end

    def copy_authorized_keys_to_git_user
      # Ensure that this is executed from the Rails root
      Dir.chdir(Rails.root.to_s) do
        Kernel.system(Settings.git_shell.copy_authorized_keys_executable.to_s)
      end
    end
  end
end
