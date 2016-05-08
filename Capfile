# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

 require 'capistrano/ec2tag'
 require 'rvm1/capistrano3'
 require 'capistrano/bundler'
 require 'capistrano/passenger'
 require 'capistrano/newrelic'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
