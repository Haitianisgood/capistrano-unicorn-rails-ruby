# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.


# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

set :rails_env, "production"
set :rack_env, "production"

set :rvm_type, :user
set :rvm_ruby_version, '2.1.5'
set :rvm_roles, [:app, :job, :web]

set :nginx_server_name, 'www.haitian.com'
set :sidekiq_role, 'job'
set :sidekiq_config, -> { File.join(current_path, 'config', 'sidekiq.yml') }
require 'net/ssh/proxy/command'

set :ssh_options, proxy: Net::SSH::Proxy::Command.new('ssh ubuntu@110.2.18.169 -W %h:%p'), forward_agent: false

server '10.10.36.25',  user: 'ubuntu', roles: %w{web app db}, :primary => true
server '10.10.51.97',  user: 'ubuntu', roles: %w{app} #app1
server '10.10.13.235', user: 'ubuntu', roles: :app #app2
server '10.10.6.63',   user: 'ubuntu', roles: %w{job}

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
