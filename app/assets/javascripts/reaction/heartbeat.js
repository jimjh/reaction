/* ========================================================================
 * heartbeat.js v0.0.2
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global $:true window:true*/

// ## reaction-heartbeat Module
// Maintains a heartbeat with the reaction server.

define(['./config'], function(config) {

  'use strict';

  var heartbeat = function() {
    $.get(config.paths.heartbeat);
    window.setTimeout(heartbeat, config.heartbeat_interval);
  }; // TODO: detect disconnect, publish event and allow reconnect

  return heartbeat();

});

