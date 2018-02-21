# frozen_string_literal: true

# Class to rewrite the authorized_keys file
class AuthorizedKeysFile
  AUTHORIZED_KEYS_FILE = '.ssh/authorized_keys'
  LOCK_FILE = 'authorized_keys.lock'
  SSH_FLAGS = ',no-port-forwarding,no-x11-forwarding,no-agent-forwarding,no-pty'

  class << self
    def write
      authorized_keys_lines = PublicKey.all.map do |key|
        authorized_keys_line(key)
      end

      FileLockHelper.exclusively(LOCK_FILE, timeout: 5.seconds) do
        authorized_keys_file.dirname.mkpath
        File.write(authorized_keys_file, authorized_keys_lines.join("\n"))
      end

      copy_authorized_keys_to_git_user
    end

    def authorized_keys_file
      Settings.data_directory.join(AUTHORIZED_KEYS_FILE)
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
