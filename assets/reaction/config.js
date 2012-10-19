/* ========================================================================
 * config.js
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://raw.github.com/jimjh/reaction/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global _:true*/

// ## reaction-config Module
// Simple object containing configuration options for the client reaction
// library.
define(['./util'], function(){
  'use strict';
  return {
    paths: {         // TODO: should be provided by rails
      root: '/',
      bayeux: '/reaction/bayeux'
    },
    id: _.uuid()             // unique uuid for this client
  };
});
