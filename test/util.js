var requirejs = require('requirejs');

//} XXX: OMG THIS IS SO FRAGILE
requirejs.config({
  baseUrl: __dirname + '/../app/assets/javascripts/',
  paths: {
    'underscore': __dirname + '/../vendor/assets/javascripts/underscore'
  },
  shim: {
    'backbone': {
      deps: ['underscore'],
      exports: 'backbone'
    }
  },
  nodeRequire: require
});

requirejs(['reaction/util'], function() {

  describe('Util', function() {

    describe('#log()', function() {
      it('should just log with no errors', function() {
        window = {};
        _.log('hello!');
      });
    });


  });
});
