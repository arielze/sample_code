require 'json'
require './lib/utils/application'
require './lib/utils/es_client'
require_relative 'data_object'

class QueryExecutor
  class << self
    def execute_seg_query(device_id, campaign_id, query)
      start = Time.now
      api_key = query[:api_key]
      user_profile_result = run_user_profile_query(api_key, device_id, query)
      user_profiles = parse_user_profile_result(user_profile_result, query[:top_group_fields])
      if user_profiles.empty?
        log_info "No user_profile found campaign_id: #{campaign_id}, device_id: #{device_id}, api_key: #{api_key}"
        return {result: false, data_bject: {}}
      end
      q_time = Time.now
      log_metrica "user_profile",  "request_time", q_time - start
      first_user_profile = user_profiles.first
      events  = run_events_query(api_key, device_id, query, first_user_profile)
      q2_time = Time.now
      log_metrica "events",  "request_time", q2_time - q_time
      total_result = parse_result(first_user_profile, events, query[:post_process])
      p_time = Time.now
      log_metrica "post_process", "time", p_time - q2_time
      total_result
    end


    def run_events_query(api_key, device_id, query, user_profile)
      events_query = query[:events_query]
      return {} if events_query[:aggs].nil? || events_query[:aggs].empty?
      events_index = "events-#{api_key}*".downcase
      events_query[:query][:filtered][:filter][:and] << {range: {event_date:{gt: user_profile['app_installation_time']}}} if user_profile['app_installation_time']
      log_info "index: #{events_index}, routing: #{device_id}, es_query:#{events_query}"
       
      es_client.search index: events_index, routing: device_id, body: events_query
    end

    def run_user_profile_query(api_key, device_id, query)
      es_client.search index: 'user_profiles', body: query[:user_profile_query]
    end


    def parse_user_profile_result(result, fields)
      return [] unless result['hits']['total'] > 0
      result['hits']['hits'].map do |h| 
        h['fields'].inject({}) do |s,d| 
          k, v = d
          s[k] = v.first
          s
        end
      end
    end


    def extract_aggregated_events_fields(aggs)
      aggs.reduce({}) do |s, agg|
        next s if agg[0] == 'doc_count'
        agg_name, agg_value = agg
        s[agg_name] = agg_value["#{agg_name}_inner"] && agg_value["#{agg_name}_inner"]["value"] 
        s
      end
    end


    def run_query(index, query)
      es_client.search index: index, body: query
    end


    def parse_result(device_fields, result, post_process)
      aggregations = result['aggregations'] || {}
      data_obj = extract_device_data device_fields, aggregations
      {result: apply_logic(post_process, data_obj), data_bject: data_obj}
    rescue => e
      log_exception "fail to parse result, device_id: result: #{result}, post_process: #{post_process}", e
      return {result: false, data_bject: data_obj, exception: e}
    end


    def extract_device_data(device_fields, aggregations)
      return device_fields if aggregations.nil? || aggregations.empty?
      device_fields.merge!(extract_aggregated_events_fields(aggregations))
    end


    def apply_logic(post_process, data_obj)
      obj = DataObject.new data_obj
      obj.instance_eval post_process
    end

  end
end
