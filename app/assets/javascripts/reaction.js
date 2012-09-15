/* ========================================================================
 * reaction.js v0.0.1.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/

// ## reaction Module
define(['reaction/config', 'reaction/cache', 'reaction/collection'],
       function(config, cache, collection){

  'use strict';

  return {
    config: config,
    Cache: cache,
    Collection: collection
  };

});
