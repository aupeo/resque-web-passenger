require 'rubygems'
require 'bundler/setup'

require 'resque/server'
require 'resque-scheduler'
require 'resque/scheduler/server'
require 'resque/status_server'
require 'resque-cleaner'

require 'json'

require 'yaml'

require 'dotenv'
Dotenv.load

ENV['REDIS_URL']||='redis://localhost:6379'

# Setup resque
Resque.redis = ENV['REDIS_URL']

Resque::Scheduler.dynamic = true

# If a password is provided, setup basic auth
if ENV['RESQUE_PWD']
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == ENV['RESQUE_PWD']
  end
end

module Resque::Plugins
  ResqueCleaner::Limiter.default_maximum = 10_000
end

use Rack::ShowExceptions

run Rack::URLMap.new \
  "/resque" => Resque::Server.new

