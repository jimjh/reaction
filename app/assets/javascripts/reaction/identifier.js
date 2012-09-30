/* ========================================================================
 * identifier.js v0.0.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global _:true*/

define(['./config', './util'], function(config) {

  'use strict';

  // Intercepts outgoing messages and adds a channel ID and signature to it.
  var outgoing = function(message, callback) {
    message.channelId = _.cookie(config.cookies.channelId);
    message.signature = _.cookie(config.cookies.signature);
    callback(message);
  };

  return { outgoing: outgoing };

});
