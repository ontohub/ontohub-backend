# frozen_string_literal: true

require 'sneakers/runner'

module Sneakers
  # Runs multiple worker groups in parallel.
  class MultiRunner
    def initialize(config)
      @pids = []
      @worker_groups = config
    end

    def run
      @worker_groups.each do |opts|
        @pids << fork do
          classes = opts[:classes].map(&:constantize)
          opts = {workers: opts[:workers]}
          Sneakers::Runner.new(classes, opts).run
        end
      end

      register_traps
    end

    private

    def register_traps
      %w(INT TERM USR1 HUP USR2).each do |signal|
        Signal.trap(signal) do
          @pids.each do |pid|
            Process.kill(signal, pid)
          rescue Errno::ESRCH
            warn_about_missing_process(signal, pid)
          end
        end
      end
      Process.waitall
    end

    def warn_about_missing_process(signal, pid)
      warn("Failed to send signal #{signal} to PID #{pid}: "\
           'Process does not exist.')
    end
  end
end
