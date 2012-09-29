/* ========================================================================
 * config.js v0.0.1.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
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
    id: _.uuid()
  };
});
