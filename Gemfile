source 'https://rubygems.org'

gem 'newrelic_rpm'

gem 'sinatra'
gem 'sinatra-contrib'
gem 'sinatra-jsonp'

gem 'hashie'
#gem 'thin'

gem 'logglier'
gem 'elasticsearch'

gem 'redis'
gem 'hiredis'

gem 'curb'

group :test do
  gem 'rspec'
end

group :development, :staging do
  gem 'better_errors'
  gem 'pry'
end

group :deploy do
  gem 'capistrano'
  gem 'capistrano-ec2tag', github: 'uriagassi/capistrano-ec2tag', branch: 'capv3'
  gem 'capistrano-passenger'
  gem 'capistrano-chruby'
  gem 'rvm1-capistrano3'
  gem 'capistrano-bundler'
  gem 'capistrano-newrelic'
end
