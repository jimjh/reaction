/* ========================================================================
 * util.js
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://raw.github.com/jimjh/reaction/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global console:true _:true window:true document:true unescape:true*/

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

  // Wrapper for `console.warn` that proxies to `_.log` if `console.warn` is
  // not defined.
  //
  //      _.warn('hello world.'); //> 'hello world'
  var warn = function() {
    var no_warner = (_.isUndefined(window.console) || _.isUndefined(console.warn));
    if (!no_warner) _.each(arguments, function(w){ console.warn(w); });
    else _.log.apply(this, arguments);
  };

  // Logs the error message and throws an error.
  //
  //      _.fatal("x is required."); //>> warning and error
  var fatal = function(error) {
    _.warn(error);
    throw new Error(error);
  };

  // Logs the error message and throws an error.
  //
  //      _.fatalf("{0} is required.", "controller_name"); //>> warning and error
  var fatalf = function() {
    var error = _.format.apply(this, arguments);
    _.fatal(error);
  };


  // Super simple sprintf, adapted from an [answer][1] on SO.
  //
  //      _.format("{0} and {1}", 'hello', 'good bye'); //>> hello and good bye
  //      _('{0} and {1}').format('hello, 'bye'); //>> hello and bye
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
    if (_.isEqual(expected, actual)) return;
    _.fatalf('Expected {0}, got {1}.', expected, actual);
  };

  // Curry function (prefilling args.)
  //
  //      function add(a, b){ return a + b; }
  //      _.curry(add, 1); //=> a function that increments its argument
  var curry = function(func, args) {
    return _.bind(func, this, args);
  };

  // Helper method for `_.uuid()`.
  var S4 = function() {
    return (((1 + Math.random())*0x10000)|0).toString(16).substring(1);
  };

  // Generates pseudo-random string by concatenating random hexadecimal.
  //
  //      _.uuid(); //=> random string
  var uuid = function() {
    return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4());
  };

  // Finds all cookies, adapted from a [gist][1].
  //
  //      _.cookies();  //=> associative array of all cookies.
  //
  //   [1]: https://gist.github.com/992303
  var cookies =  function() {
    var _cookies = {};
    _(document.cookie.split(';'))
      .chain()
      .map(function(m) { return m.replace(/^\s+/, '').replace(/\s+$/, ''); })
      .each(function(c) {
      var arr = c.split('='),
          key = arr[0],
          value = null;
      var size = _.size(arr);
      if (size > 1) value = arr.slice(1).join('');
      _cookies[key] = unescape(value);
    });
    return _cookies;
  };

  // Finds the value for the specific cookie. If cookie does not exist, returns
  // `undefined`.
  //
  //      _.cookie('id'); //=> value of `id`
  var cookie = function(name) {
     return _.cookies()[name];
  };

  _.mixin({
    log: log,
    logf: logf,
    warn: warn,
    fatal: fatal,
    fatalf: fatalf,
    format: format,
    assert: assert,
    curry: curry,
    uuid: uuid,
    cookies: cookies,
    cookie: cookie
  });

});
