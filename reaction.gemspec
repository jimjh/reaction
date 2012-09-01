# -*- encoding: utf-8 -*-
require File.expand_path('../lib/reaction/version', __FILE__)

Gem::Specification.new do |gem|

  gem.authors       = ["Jiunn Haur Lim"]
  gem.email         = ["codex.is.poetry@gmail.com"]
  gem.description   = %q{Reactive framework for Ruby web apps. Inspired by Meteor. It's is a work in progress, but check the github repo for updates.}
  gem.summary       = %q{Reactive framework for Ruby web apps.}
  gem.homepage      = "http://github.com/jimjh/reaction"
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "reaction"
  gem.require_paths = ["lib"]
  gem.version       = Reaction::VERSION

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'debugger-pry'

end
