require "rubygems"
require "bundler"

Bundler.require :default

require File.dirname(__FILE__)+"/api"

Api.redis = ENV["REDIS_URL"]

run Api::Application.new
