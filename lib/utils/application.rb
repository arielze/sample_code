require 'yaml'
require 'hashie'
require 'logglier'
require 'newrelic_rpm'
require_relative 'env'


module Application
  extend Env

  class << self
    def config

      @config ||= Hashie::Mash.load('./config/application.yml')[env.to_s]
      return @conf if @conf && @conf.size>0
      all_env_config=Hashie::Mash.load('./config/application.yml')

      @conf = Hashie::Mash.new
      @conf.merge!(all_env_config.defaults) if all_env_config.defaults?
      @conf.merge!(all_env_config[env.to_s]) if (all_env_config[env.to_s])
      @conf      
    end

    def logger
      @logger ||= begin
        case env
        when :production, :staging
          Logglier.new("https://logs-01.loggly.com/inputs/#{app_config.log.token}/tag/#{[Env.env, app_config.log.name].join(',')}/", :threaded => true, :format => :json)
        else 
          Logger.new(STDOUT)
          #Logger.new './log/es_query_executor.log'
        end
      end
    end
  end
end


def app_config
  Application.config
end

def app_logger
  Application.logger
end



def log_error(message)
  app_logger.error error_messagr: message
  ::NewRelic::Agent.agent.error_collector.notice_error( message )
rescue => e
  puts e
end

def log_exception(message, e)
  app_logger.error error_message: message, exception_message: e, backtrace: e.backtrace
  ::NewRelic::Agent.agent.error_collector.notice_error( e )
rescue => e
  puts e
end

def log_info(message)
  app_logger.info message: message
end

def log_metrica(context, metric, value)
  app_logger.info message: "#{context}_#{metric}", value: value
  ::NewRelic::Agent.record_metric("Custom/#{context}/#{metric}", value)
rescue
  nil
end


class ExceptionLogger
  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      @app.call env
    rescue => exception

      exception_message = "#{exception.class}: #{exception.message}\n"
      exception_message << exception.backtrace.take(10).map { |l| "\t#{l}" }.join("\n")

      app_logger.error exception_message

      [500, {'Content-Type' => 'text/plain'}, ["Server Internal error"]]
    end
  end
end