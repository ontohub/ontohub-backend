# frozen_string_literal: true

class Git
  # Methods for committing
  module Cloning
    class Error < StandardError; end
    class InvalidRemoteError < Error; end

    # ... that are invoked from the class
    module ClassMethods
      def clone(path, remote)
        if remote_git?(remote)
          clone_git(path, remote)
        # rubocop:disable Lint/AssignmentInCondition
        elsif layout = remote_svn_layout(remote) # remote_svn?
          clone_svn(path, remote, layout)
        else
          raise InvalidRemoteError
        end
        new(path)
      end

      protected

      def clone_git(path, remote)
        Popen.popen(%W(git clone --mirror #{remote} #{path}))
      end

      def clone_svn(path, remote, layout)
        Dir.mktmpdir do |tmpdir|
          tmppath = clone_svn_to_temppath(remote, layout, tmpdir)
          convert_to_bare_and_move_to_path(path, tmppath)
        end
      end

      def clone_svn_to_temppath(remote, layout, tmpdir)
        tmppath = File.join(tmpdir, 'clone.git-svn')
        if layout == :standard
          Popen.popen(%W(git svn clone --stdlayout #{remote} #{tmppath}))
        else
          Popen.popen(%W(git svn clone #{remote} #{tmppath}))
        end
        tmppath
      end

      def convert_to_bare_and_move_to_path(path, tmppath)
        FileUtils.mkdir_p(File.dirname(path))
        FileUtils.mv(File.join(tmppath, '.git'), path)
        Popen.popen(%w(git config --bool core.bare true), path)
      end

      def remote_git?(remote)
        # GIT_ASKPASS is set to the 'true' executable. It simply returns
        # successfully. This way, no credentials are supplied.
        _out, status = Popen.popen(%w(git ls-remote -h) + [remote],
                                   nil,
                                   'GIT_ASKPASS' => 'true')
        status.zero?
      end

      def remote_svn_layout(remote)
        out, status = Popen.popen(%w(svn ls) + [remote])
        if status.zero?
          if out.split("\n") == %w(branches/ tags/ trunk/)
            :standard
          else
            :non_standard
          end
        else
          false
        end
      end
    end
  end
end
