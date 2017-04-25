# frozen_string_literal: true

class Git
  # Methods for pulling
  module Pulling
    class Error < StandardError; end

    def pull
      if svn?
        pull_svn
      else
        pull_git
      end
    end

    protected

    def svn?
      path.join('svn').directory?
    end

    def pull_svn
      _out_fetch, status_fetch = Popen.popen(%w(git svn fetch), path.to_s)

      ref = svn_has_trunk? ? 'trunk' : 'git-svn'
      cmd = %W(git update-ref refs/heads/master refs/remotes/#{ref})
      _out_update, status_update = Popen.popen(cmd, path.to_s)

      [status_fetch, status_update].all?(&:zero?)
    end

    def pull_git
      _out, status = Popen.popen(%w(git fetch --all), path.to_s)
      status.zero?
    end

    def svn_has_trunk?
      out, _status = Popen.popen(%w(git config svn-remote.svn.fetch), path.to_s)
      out.start_with?('trunk:')
    end
  end
end
