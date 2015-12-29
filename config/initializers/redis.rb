# location = ENV["REDISCLOUD_URL"] || 'redis://127.0.0.1:6379/0'
# uri = URI.parse(location)
# $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

# r = Redis.new
#
# heartbeat_thread = Thread.new do
#   while true
#     r.publish "heartbeat", "thump"
#     sleep 2.seconds
#   end
# end
#
# at_exit do
#   heartbeat_thread.kill
#   r.quit
# end
