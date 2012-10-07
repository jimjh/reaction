# Reaction

[![Build Status](https://secure.travis-ci.org/jimjh/reaction.png)](http://travis-ci.org/jimjh/reaction)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/jimjh/reaction)

This gem combines [Backbone][backbone]'s MVC and [Faye][faye]'s push
capabilities to make data synchronization between the client's local storage
and the server's database easy and almost transparent.  Refer to
[reaction-todos][todos] for an example.

This is still an alpha version. Reaction uses [YARD][yard] for ruby
documentation and [Groc][groc] for Javascript documentation.

## Installation

Add this line to your application's Gemfile:

    gem 'reaction'

And then execute:

    $ bundle install

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Add tests and make sure everything still passes by running `rake`
1. Commit your changes (`git commit -am 'Added some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request

## Developing

To use the development copy of the gem, add the following line in your application's Gemfile:

    gem 'reaction', :path => '/path/to/gem'

* Use [Pry][pry] and [RSpec][rspec] for debugging and testing Ruby code (see [spec][spec])
* Use [RequireJS][require], [Mocha][mocha], [Sinon][sinon] for developing and testing Javascript code (see [test][test])


  [todos]: https://github.com/jimjh/reaction-todos
  [backbone]: http://backbonejs.org
  [faye]: http://faye.jcoglan.com
  [yard]: http://yardoc.org/
  [groc]: http://nevir.github.com/groc/
  [mocha]: http://visionmedia.github.com/mocha/
  [require]: http://requirejs.org/
  [pry]: http://pryrepl.org/
  [rspec]: http://rspec.info/
  [sinon]: http://sinonjs.org/
  [spec]: https://github.com/jimjh/reaction/tree/master/spec
  [test]: https://github.com/jimjh/reaction/tree/master/test
