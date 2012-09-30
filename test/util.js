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
        var stub = sinon.stub(console, 'log');
        window = {console: console};
        _.log('yup it is working.', 'this should be on another line.');
        stub.called.should.eql(true);
        stub.restore();
      });

    });

    describe('#warn()', function() {

      it('should just warn with no errors without console', function() {
        window = {};
        _.warn();
        _.warn('warning...');
      });

      it('should warn to console if it is defined', function() {
        var stub = sinon.stub(console, 'warn');
        window = {console: console};
        _.warn('testing fire alarm - do not evacuate.');
        stub.called.should.eql(true);
        stub.restore();
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

    describe('#assert()', function() {

      it('should throw an error if two values are not equal', function() {
        var stub = sinon.stub(console, 'warn');
        (function(){_.assert(0, 1);}).should.throw('Expected 0, got 1.');
        (function(){_.assert('a', 'b');}).should.throw('Expected a, got b.');
        (function(){_.assert([1,2], [3,4]);}).should.throw('Expected 1,2, got 3,4.');
        (function(){_.assert({x:'y'}, {a:'b'});}).should.throw();
        stub.restore();
      });

      it('should not throw an error if two values are equal', function() {
        var stub = sinon.stub(console, 'warn');
        (function(){_.assert(0, 0);}).should.not.throw();
        (function(){_.assert('aab', 'aab');}).should.not.throw();
        (function(){_.assert([1,2], [1,2]);}).should.not.throw();
        (function(){_.assert({x:'y'}, {x:'y'});}).should.not.throw();
        stub.restore();
      });

    });

    describe('#uuid()', function() {

      it('should generate unique UUIDs', function() {
        var values = [];
        for(var i = 0; i < 10; i++) {
          var uuid = _.uuid();
          values.should.not.includeEql(uuid);
          values.push(uuid);
        }
      });

    });

    describe('#cookies()', function() {
      it('should retrieve an associative array of cookies', function() {
        document = {cookie: "   a=0;b=1    ;c=2;d=x====y   ;e=x%3D%3D%3D%3Dy"};
        _.cookies().should.eql({
          a: '0',
          b: '1',
          c: '2',
          d: 'xy',
          e: 'x====y'
        });
      });
    });

    describe('#cookie()', function() {
      it('should retrieve values for each cookie', function() {
        document = {cookie: "   a=0;b=1    ;c=2;d=x====y   ;e=x%3D%3D%3D%3Dy"};
        _.cookie('a').should.eql('0');
        _.cookie('b').should.eql('1');
        _.cookie('c').should.eql('2');
        _.cookie('d').should.eql('xy');
        _.cookie('e').should.eql('x====y');
        _.isUndefined(_.cookie('f')).should.eql(true);
      });
    });

    describe('#fatal()', function() {
      it('should log a warning and throw an error', function() {
        var stub = sinon.stub(console, 'warn');
        (function(){_.fatal('x is required');}).should.throw('x is required');
        stub.called.should.eql(true);
        stub.restore();
      });
    });

    describe('#fatalf()', function() {
      it('should log a warning and throw an error', function() {
        var stub = sinon.stub(console, 'warn');
        (function(){_.fatalf('{0} is required', 'x');}).should.throw('x is required');
        stub.called.should.eql(true);
        stub.restore();
      });
    });

  });
});
