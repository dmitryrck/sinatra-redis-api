require "rubygems"
require "bundler"

Bundler.require :default

require File.dirname(__FILE__)+"/api"

use Rack::PostBodyContentTypeParser
run Api::Application.new
