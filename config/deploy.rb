set :application, 'es_query_executor'
set :repo_url, "git@github.com:arielze/#{fetch :application}"

set :branch, ENV['branch'] || proc { `git rev-parse --abbrev-ref HEAD`.chomp } || 'master'

set :ruby_version, "2.1.5"
set :rvm_ruby_version, '2.1.5'


set :deploy_to, "/home/ubuntu/#{fetch :application}"
set :scm, :git

set :format, :pretty
set :log_level, :debug
# set :pty, true
set :ssh_options, {keys: ['~/.ssh/id_rsa'], forward_agent: true}

# set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{log pids tmp}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

namespace :deploy do
  # all deploy tasks are defined in capistrano-passenger

end

after 'deploy:finished', 'newrelic:notice_deployment'


