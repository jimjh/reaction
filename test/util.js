var requirejs = require('./test_helper'),
    sinon = require('sinon');
require('sinon-mocha').enhance(sinon);

requirejs(['reaction/util'], function() {

  describe('Util', function() {

    describe('#log()', function() {

      it('should just log with no errors without console', function() {
        window = {};
        _.log();
        _.log('hello!');
      });

      it('should log to console if it is defined', function() {
        window = {console: console};
        sinon.spy(console, 'log');
        _.log();
        _.log('yup it is working.', 'this should be on another line.');
        console.log.called.should.eql(true);
      });

    });

    describe('#warn()', function() {

      it('should just warn with no errors without console', function() {
        window = {};
        _.warn();
        _.warn('warning...');
      });

      it('should warn to console if it is defined', function() {
        window = {console: console};
        sinon.spy(console, 'warn');
        _.warn();
        _.warn('testing fire alarm - do not evacuate.');
        console.warn.called.should.eql(true);
      });

    });

    describe('#logf()', function() {

      it('should log with my lovely sprintf', function() {
        var stub = sinon.stub(_, 'log');
        _.logf('{0} {1}', 'hello', 'world');
        stub.calledWith('hello world').should.eql(true);
        stub.restore();
      });

    });

    describe('#format()', function() {

      it('should return undefined if called with no args', function() {
        _.isUndefined(_.format()).should.eql(true);
      });

      it('should ignore placeholders with missing values', function() {
        _.format('{0} {1}', 'x').should.eql('x {1}');
      });

      it('should replace placeholders with strings/numbers', function() {
        _.format('{0} {1}', 'hey', 'there!').should.eql('hey there!');
        _.format('My fave {0} is {1}', '#', 7).should.eql('My fave # is 7');
        _.format('{0} --> {1}', [1,2], [4,5]).should.eql('1,2 --> 4,5');
      });

    });


  });
});
