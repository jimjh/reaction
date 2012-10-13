ENV['RACK_ENV'] = 'test'
require 'reaction'
require 'debugger/pry'

shared_glob = File.expand_path 'shared/**/*.rb', File.dirname(__FILE__)
Dir[shared_glob].each { |f| require f }

matchers_glob = File.expand_path 'matchers/**/*.rb', File.dirname(__FILE__)
Dir[matchers_glob].each { |f| require f }
