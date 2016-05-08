set :stage, :staging

invoke 'ec2tag:tag', "#{fetch :application}_staging", set_to: :server, user: 'ubuntu', roles: %w{app web sneakers}, ssh_options: {keys: '~/.aws/wso2.pem'}, :primary => true






