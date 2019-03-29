require "rubygems"
require "bundler"

Bundler.require :default, :test

ENV["RACK_ENV"] = "test"

require File.dirname(__FILE__)+"/../api"

RSpec.configure do |config|
  include Rack::Test::Methods

  def app
    Api::Application
  end
end
