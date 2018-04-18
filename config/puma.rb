# frozen_string_literal: true

# Bind on a specific TCP address. We won't bother using unix sockets because
# nginx will be running in a different Docker container.
bind "tcp://#{ENV['BIND_ON']}"

# Puma supports threading. Requests are served through an internal thread pool.
# Even on MRI, it is beneficial to leverage multiple threads because I/O
# operations do not lock the GIL. This typically requires more CPU resources.
#
# More threads will increase CPU load but will also increase throughput.
#
# Like anything this will heavily depend on the size of your instance and web
# application's demands. 5 is a relatively safe number, start here and increase
# it based on your app's demands.
#
# RAILS_MAX_THREADS will match the default thread size for Active Record.
threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
threads threads_count, threads_count

# Puma supports spawning multiple workers. It will fork out a process at the
# OS level to support concurrent requests. This typically requires more RAM.
#
# If you're looking to maximize performance you'll want to use as many workers
# as you can without starving your server of RAM.
#
# This value isn't really possible to auto-calculate if empty, so it defaults
# to 2 when it's not set. That is heavily leaning on the safe side.
#
# Ultimately you'll want to tweak this number for your instance size and web
# application's needs.
#
# If using threads and workers together, the concurrency of your application
# will be THREADS * WORKERS.
workers ENV.fetch('WEB_CONCURRENCY') { 2 }

# An internal health check to verify that workers have checked in to the master
# process within a specific time frame. If this time is exceeded, the worker
# will automatically be rebooted. Defaults to 60s.
#
# Under most situations you will not have to tweak this value, which is why it
# is coded into the config rather than being an environment variable.
worker_timeout 30

# The path to the puma binary without any arguments.
restart_command 'puma'

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory. If you use this option
# you need to make sure to reconnect any threads in the `on_worker_boot`
# block.
#
# preload_app!

# If you are preloading your application and using Active Record, it's
# recommended that you close any connections to the database before workers
# are forked to prevent connection leakage.
#
# before_fork do
#   ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
# end

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted, this block will be run. If you are using the `preload_app!`
# option, you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, as Ruby
# cannot share connections between processes.
#
# on_worker_boot do
#   ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
# end
#

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
