set :stage, :preprod

invoke 'ec2tag:tag', "#{fetch :application}_preprod", set_to: :server, user: 'ubuntu', roles: %w{app web sneakers}, ssh_options: {keys: '~/.aws/touchbeam-prod.pem'}, :primary => true