require 'json'
require 'curb'
require './lib/utils/application'
require './lib/utils/redis_client'


class QueriesRepository
  class << self
    def campaign_query(campaign_id)
      key = "campaign_query_#{campaign_id}"
      redis_client.get(key) || retrive_campaign_query(campaign_id, key)
    end

    def retrive_campaign_query(campaign_id, key)
      res = ::Curl.get("#{app_config.api_server}/api/v1/segment_queries/es_query/#{campaign_id}")
      data = res.body
      if res.response_code == 200
        redis_client.setex key, 36000, data # 10 minutes cache
        data
      else
        log_error "QueriesRepository#retrieve_campaign_query campaign_id: #{campaign_id}, key: #{key},  error_message: #{data}"
        {}
      end
    rescue => e
      log_exception "QueriesRepository#retrieve_campaign_query campaign_id: #{campaign_id}, key: #{key}", e
      {}
    end
  end
end
