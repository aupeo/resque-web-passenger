require 'rubygems'
require 'bundler/setup'

require 'resque/server'
require 'resque-scheduler'
require 'resque/scheduler/server'
require 'resque/status_server'
require 'json'

require 'yaml'

# Our config
f1 = File.expand_path('../resque-web.yml', __FILE__)
if File.exists?(f1)
    config = YAML.load_file(f1)
else
    config = { resque: {} }
end

# Load resque config
f2 = config['resque']['config_path']
if File.exists?(f2)
    redis_config = YAML.load_file(f2)
    redis_config = redis_config[ config['resque']['environment'] ] if config['resque']['environment']
else
    redis_config = 'localhost:6379'
end

# Setup resque
Resque.redis = redis_config
Resque.redis.namespace = config['resque']['namespace'] if config['resque']['namespace']

Resque::Scheduler.dynamic = true

# If a password is provided, setup basic auth
if config['password']
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == config['password']
  end
end

use Rack::ShowExceptions

run Rack::URLMap.new \
  "/resque" => Resque::Server.new

