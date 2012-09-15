/* ========================================================================
 * util.js v0.0.1.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global console:true _:true window:true*/

// ## reaction-util Module
// Collection of utility functions that I like.
define(['underscore'], function(){

  'use strict';

  // Wrapper for `console.log` that does nothing if `console.log` is not
  // defined.
  //
  //     _.log('hello world.'); //>> 'hello world'
  var log = function() {
    var no_logger = (_.isUndefined(window.console) || _.isUndefined(console.log));
    if(!no_logger) _.each(arguments, function(m){ console.log(m); });
  };

  // Sprintf + Log.
  //
  //      _.logf("{0} and {1}", "hello", "bye") //>> hello and bye
  var logf = function() {
    _.log(_.format.apply(this, arguments));
  };

  // Super simple sprintf, adapted from an [answer][1] on SO.
  //
  //      _.format("{0} and {1}", 'hello', 'good bye');
  //      _('{0} and {1}').format('hello, 'bye');
  //
  //   [1]: http://stackoverflow.com/questions/610406/javascript-equivalent-to-printf-string-format
  var format = function(format) {
    var args = _(arguments).rest();
    for(var i in args) format = format.replace("{" + i + "}", args[i]);
    return format;
  };

  // Asserts equality of two values. Throws an error if they are not equal.
  //
  //      _.assert(0, 1); //>> throws error
  var assert = function(expected, actual) {
    if (expected === actual) return;
    throw {error: _('expected {0}, got {1}').format(expected, actual)};
  };

  // Curry function (prefilling args.)
  //
  //      function add(a, b){ return a + b; }
  //      _.curry(add, 1); //=> a function that increments its argument
  var curry = function(func, args)  {
    return _.bind(func, this, args);
  };

  _.mixin({
    log: log,
    logf: logf,
    format: format,
    assert: assert,
    curry: curry
  });

});
