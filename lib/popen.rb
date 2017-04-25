# frozen_string_literal: true

require 'fileutils'
require 'open3'

# Methods for opening the commandline client
module Popen
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.popen(cmd, path = nil, vars = {})
    unless cmd.is_a?(Array)
      raise 'System commands must be given as an array of strings'
    end

    path ||= Dir.pwd
    vars = vars.dup
    vars['PWD'] = path
    options = {chdir: path}

    FileUtils.mkdir_p(path) unless File.directory?(path)

    cmd_output = ''
    cmd_status = 0
    Open3.popen3(vars, *cmd, options) do |stdin, stdout, stderr, wait_thr|
      yield(stdin) if block_given?
      stdin.close

      cmd_output += stdout.read
      cmd_output += stderr.read
      cmd_status = wait_thr.value.exitstatus
    end

    [cmd_output, cmd_status]
  end
end
