set :stage, :production

invoke 'ec2tag:tag', "#{fetch :application}_production", set_to: :server, user: 'ubuntu', roles: %w{app web sneakers}, ssh_options: {keys: '~/.aws/touchbeam-prod.pem'}, :primary => true