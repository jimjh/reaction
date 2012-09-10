#!/usr/bin/env rake
require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new 'spec'

desc 'runs all RSpec test examples'
task :default => :spec

# TODO: write a raketask to compile/optimize javascripts (exclude vendor
# scripts)

# TODO: write a raketask to build the gem

# TODO: write a raketask to release the gem

namespace :doc do

  desc 'Generate documentation for javascripts'
  task :js do
    sh 'groc'
  end

  desc 'Generate documentation for ruby scripts'
  task :rb do
    sh 'yard doc --output-dir rb-doc'
  end

  desc 'Generate documentation for ruby and javascript'
  task :all => [:js, :rb]

end
