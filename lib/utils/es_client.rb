require 'elasticsearch'
require_relative 'application'


class ElasticsearchClient

  def client
    @client ||= Elasticsearch::Client.new hosts: [*app_config.elasticsearch.hosts]
  end
end


def es_client 
  @es_client ||= ElasticsearchClient.new.client
end
