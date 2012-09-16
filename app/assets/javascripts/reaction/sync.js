/* ========================================================================
 * sync.js v0.0.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/

// # reaction-sync Module
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
        else cache.findAll(options);
        break;
      case 'create':
        cache.create(model, options);
        break;
      case 'update':
        cache.update(model);
        break;
      case 'delete':
        cache.destroy(model, options);
        break;
    }

  };

  return sync;

});

