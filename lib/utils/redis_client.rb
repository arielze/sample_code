require 'redis'
require 'hiredis'
require_relative 'application'

class RedisClient
  class << self
    def client
      @redis ||= Redis.new(host: app_config.redis, port: 6379, db: 10, driver: :hiredis)
    end
  end
end

def redis_client
  RedisClient.client
end
