var requirejs = require('./test_helper');

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
