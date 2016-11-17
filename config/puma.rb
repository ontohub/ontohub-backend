# frozen_string_literal: true

# Specifies the `environment` that Puma will run in.
#
@environment = ENV.fetch('RAILS_ENV') { 'development' }
environment @environment
def production?
  @environment == 'production'
end

# Specifies the `port` that Puma will listen on to receive requests, default is
# 3000.
#
port ENV.fetch('PORT') { 3000 }

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
threads_count = ENV.fetch('RAILS_MAX_THREADS') { production? ? 1 : 5 }.to_i
threads threads_count, threads_count

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
workers ENV.fetch('WEB_CONCURRENCY') { 24 }.to_i if production?

# Disable request logging.
# The default is "false".
quiet if production?

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
preload_app! if production?

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
if production?
  on_worker_boot do
    # let's make sure, that users with the same GID as the running puma process
    # are really able to control puma (the group needs write access). See option
    # --control and --control-url above.
    if @options[:control_url]
      uri = URI.parse(@options[:control_url])
      FileUtils.chmod(0o770, uri.path) if uri.scheme == 'unix'
    end
    # Load the models
    ::SequelRails.setup @environment
  end
end

# Code to run immediately before the master starts workers:
# Disconnect from the database before creating a worker.
if production?
  before_fork do
    ::Sequel::Model.db.disconnect
  end
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
