#!/usr/bin/env rake
require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new 'spec'

desc 'runs all RSpec test examples'
task :default => [:test, :spec]

desc 'Executes the Javascript test cases'
task :test do
  sh 'mocha', 'test'
end

namespace :doc do

  desc 'Generate documentation for javascripts'
  task :js do
    sh 'groc'
  end

  YARD::Rake::YardocTask.new do |t|
    t.options = ['--output-dir', 'doc/rb']
  end

  desc 'Generate documentation for ruby scripts'
  task :rb => [:yard]

  desc 'Generate documentation for ruby and javascript'
  task :all => [:js, :rb]

end
