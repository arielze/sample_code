require 'sinatra'
require 'sinatra/jsonp'
require 'sinatra/cookies'

require './es_query_executer.rb'

use Rack::Deflater

run Sinatra::Application
