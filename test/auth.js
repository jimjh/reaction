var requirejs = require('./test_helper'),
    sinon = require('sinon');

requirejs(['reaction/auth'], function(auth) {

  describe('Auth', function() {

    // simple mocking
    navigator = {userAgent: 'xMEN'};
    $ = function() {
      return {attr: function() { return 'x'; }};
    };

    it('should create an object with an outgoing method', function() {
      auth(null).should.have.property('outgoing').with.instanceOf(Function);
    });

    it('should not override existing ext values', function() {
      var extension = auth(null);
      var message = {ext: {hello: 'world'}};
      extension.outgoing(message, _.identity);
      message.should.have.property('ext').with.property('hello', 'world');
    });

    it('should append given options to the message', function() {
      var extension = auth({a: 'b', c: 0});
      var message = {};
      extension.outgoing(message, _.identity);
      message.should.have.property('ext').with.property('auth');
      message.ext.auth.should.have.property('a', 'b');
      message.ext.auth.should.have.property('c', 0);
    });

    // weak test here - use phantomJS for stronger test
    it('should add user agent and csrf to message', function() {
      var extension = auth({a: 'b', c: 1});
      var message = {};
      extension.outgoing(message, _.identity);
      message.ext.auth.should.have.property('user_agent', 'xMEN');
      message.ext.auth.should.have.property('csrf', 'x');
    });

  });

});
