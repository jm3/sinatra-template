require File.dirname(__FILE__) + '/../site.rb'

require 'rspec'
require 'rack/test'
require 'nokogiri'

set :environment, :test

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def app
  Sinatra::Application
end

GA_ACCOUNT_ID = "UA-XXXXXX-X"
