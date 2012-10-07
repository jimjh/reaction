/* ========================================================================
 * sync.js
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://raw.github.com/jimjh/reaction/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/

// # reaction-sync Module
// Provides a sync function for Backbone that uses a write-through cache.
define(['reaction/util'], function(){

  'use strict';

  // Overrides Backbone.sync to use Reaction.Cache.
  var sync = function(method, model, options) {

    var cache = this.cache || this.collection.cache;

    var success = options.success;
    options.success = function(resp, status, xhr) {
      if (success) success(resp, status, xhr);
      model.trigger('sync', model, resp, options);
    };

    var error = options.error;
    options.error = function(xhr) {
      if (error) error(model, xhr, options);
      model.trigger('error', model, xhr, options);
    };

    switch(method) {
      case 'read':
        if (model.id) cache.find(model, options);
        else cache.fetch(model, options);
        break;
      case 'create':
        cache.create(model, options);
        break;
      case 'update':
        cache.update(model, options);
        break;
      case 'delete':
        cache.destroy(model, options);
        break;
    }

  };

  return sync;

});

