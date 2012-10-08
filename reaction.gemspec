# -*- encoding: utf-8 -*-
require File.expand_path('../lib/reaction/version', __FILE__)

Gem::Specification.new do |gem|

  gem.authors       = ["Jiunn Haur Lim"]
  gem.email         = ["codex.is.poetry@gmail.com"]
  gem.description   = %q{Reactive framework for Ruby web apps. Inspired by Meteor. It's a work in progress, but check the github repo for updates.}
  gem.summary       = %q{Reactive framework for Ruby web apps.}
  gem.homepage      = "http://github.com/jimjh/reaction"
  gem.license       = 'MIT'

  gem.files         = %w(README.md LICENSE) + Dir.glob("lib/**/*") + Dir.glob("app/**/*")
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "reaction"
  gem.require_paths = ["lib"]
  gem.version       = Reaction::VERSION

  # Test Stuff
  gem.add_development_dependency 'rspec', '~> 2.11'
  gem.add_development_dependency 'rake', '~> 0.9'
  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'debugger-pry'
  gem.add_development_dependency 'capybara', '~> 1.0'
  gem.add_development_dependency 'poltergeist', '~> 1.0'

  # Documentation Stuff
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'

  # Rails Stuff
  gem.add_development_dependency 'rails', '>= 3.2.8'
  gem.add_development_dependency 'rspec-rails'
  gem.add_development_dependency 'thin', '~> 1.4'
  gem.add_development_dependency 'sqlite3'

  gem.add_dependency 'faye', '~> 0.8.4'

end
