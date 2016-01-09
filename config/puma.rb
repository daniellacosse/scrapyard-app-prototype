workers Integer(ENV["WEB_CONCURRENCY"] || 4)
threads_count = Integer(ENV["MAX_THREADS"] || 16)
threads threads_count, threads_count

preload_app!

rackup      DefaultRackup
port        ENV["PORT"]     || 3000
environment ENV["RACK_ENV"] || "development"

on_worker_boot do
  ActiveRecord::Base.establish_connection

  # Worker specific setup for Rails 4.1+
  $redis = Redis.new(url: ENV["REDIS_URL"] || "redis://localhost:6379/0")
end
