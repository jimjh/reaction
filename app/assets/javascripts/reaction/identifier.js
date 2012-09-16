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

define(['reaction/util'], function() {

  'use strict';

  var CHANNEL_ID = 'channel_id';

  // Intercepts outgoing messages and adds a channel ID to it.
  var outgoing = function(message, callback) {
    message.channel_id = _.cookie(CHANNEL_ID);
    callback(message);
  };

  return { outgoing: outgoing };

});
