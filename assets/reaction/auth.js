/* ========================================================================
 * auth.js
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://raw.github.com/jimjh/reaction/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global _:true navigator:true $:true*/

define(function() {

  'use strict';

  return function(options) {

    // Intercepts outgoing messages and adds an authentication object to them.
    var outgoing = function(message, callback) {

      _.defaults(message, {ext: {}});
      options = _.defaults(options || {}, {
        user_agent: navigator.userAgent,
        csrf: $('meta[name=csrf-token]').attr('content') // FIXME: fragile
      });

      message.ext.auth = options;
      callback(message);

    };

    return { outgoing: outgoing };

  };

});
