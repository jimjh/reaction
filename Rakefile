#!/usr/bin/env rake
require 'bundler'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

RSpec::Core::RakeTask.new 'spec'

desc 'runs all RSpec test examples'
task :default => [:spec, :test]

# TODO: write a raketask to compile/optimize javascripts (exclude vendor
# scripts)

desc 'Executes the Javascript test cases'
task :test do
  sh 'npm test'
end

namespace :doc do

  desc 'Generate documentation for javascripts'
  task :js do
    sh 'groc'
  end

  YARD::Rake::YardocTask.new do |t|
    t.options = ['--output-dir', 'rb-doc']
  end

  desc 'Generate documentation for ruby scripts'
  task :rb => [:yard]

  desc 'Generate documentation for ruby and javascript'
  task :all => [:js, :rb]

end

namespace :ci do

  desc 'Install PhantomJS'
  task :install_phantomjs do
    sh <<-script
      sudo su -c \
      'version=phantomjs-1.7.0-linux-i686;
       wget http://phantomjs.googlecode.com/files/$version.tar.bz2;
       tar xjf $version.tar.bz2;
       mv $version phantomjs;
       exit'
    script
  end

end
