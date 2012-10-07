/* ========================================================================
 * reaction.js
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://raw.github.com/jimjh/reaction/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/

// # Reaction Client
// Interacts with the reaction server to bring reactivity to Ruby webapps.
// Currently only supports Rails.
//
// See main.js for an example of how to include this in your app.
//
// ## Interface
// * `Collection`: constructor for a reaction collection
define(['reaction/config', 'reaction/cache', 'reaction/model', 'reaction/collection'],
       function(config, cache, model, collection){

  'use strict';

  return {
    config: config,
    Cache: cache,
    Model: model,
    Collection: collection
  };

});
