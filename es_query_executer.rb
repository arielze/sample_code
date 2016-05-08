require 'sinatra'
require 'newrelic_rpm'
require './lib/utils/application'
require './lib/query_executor'
require './lib/queries_repo'

configure :development do
  require 'sinatra/reloader'
end

configure do
  #remove logging except for exceptions
  Logger.class_eval { alias :write :'<<' }
  set :logging, false
  set :show_exceptions, false
  set :dump_errors, false
  set :raise_errors, true
  use ExceptionLogger
end

get '/seg_query/:campaign_id/:device_id' do
  query_string = QueriesRepository.campaign_query params[:campaign_id]
  halt 500, "couldn't retrieve campaign_id #{params[:campaign_id]}" if query_string.empty?
  query_string.gsub! "[[my_device_id]]", params[:device_id]
  query = JSON.parse query_string , symbolize_names: true

  app_logger.info message: "Seg Query", api_key: params[:api_key], device_id: params[:device_id], query: query

  res = QueryExecutor.execute_seg_query params[:device_id], params[:campaign_id], query

  if params[:pretty]
    res.to_json
  else
    res[:result] ? (status 200) : (status 404)
  end
end

get '/servicecheck' do
  'OK'
end

get '/sanity_check' do
  begin
    res =  QueryExecutor.run_query '',{size:1, query:{filtered: {filter: {range: {event_date: {gte: "now-5m"}}}}}}
    if res['hits']['total'] > 0 
      status(200) 
    else
      log_error  "Total new data in the last minute to low #{res['hits']['total']}"
      status(500)
    end
    parse_response res

  rescue Exception => e
    log_exception "query: #{query}, error_message: #{e.message}", e 
    status 500
    {query: query, error_message: e.message, backtrace: e.backtrace}
  end
end

def parse_response(obj)
  if(obj.nil?)
    status 500
    return {}
  end
  params[:pretty] == "1" ? JSON.pretty_generate(obj) : obj.to_json
end
