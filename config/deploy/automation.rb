set :stage, :automation

invoke 'ec2tag:tag', "#{fetch :application}_automation", set_to: :server, user: 'ubuntu', roles: %w{app web sneakers}, ssh_options: {keys: '~/.aws/wso2.pem'}, :primary => true






