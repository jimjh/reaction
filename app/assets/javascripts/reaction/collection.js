/* ========================================================================
 * collection.js v0.0.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global _:true Backbone:true $:true*/

//} TODO: improve documentation.

// # reaction-collection Module
define(['reaction/cache', 'reaction/config', 'reaction/util', 'backbone'],
       function(Cache) {

  'use strict';

  var Collection = Backbone.Collection.extend({

    // Creates a new collection tied to a Rails model of the same name.
    // Options:
    // * `onReady`: invoked when the DOM has been fully loaded and the data is
    //              ready. This can't be an event, because there is no
    //              guarantee that the handler will be registered before the
    //              event is fired. Takes an `events` parameter.
    //}             XXX: maybe this can be a parameter on its own.
    initialize: function(name, options) {

      // Throws error if `name` is undefined or empty.
      if (_.isEmpty(name)) throw {error: 'model must not be undefined or empty.'};

      var that = this;
      this.name = name;
      options = _.defaults(options || {}, {
        onReady: function(){}
      });

      // onData is invoked by the cache when the data is ready.
      options.onData = function(items){
        that.reset(items);
        $(options.onReady(items));
      };

      this.cache = new Cache(name, options);

    },

    // Overrides Backbone.sync to use Reaction.Cache.
    sync: function(method, model, options) {

      var resp;
      var cache = this.cache;

      switch(method) {
        case 'read':
          resp = model.id ? cache.find(model) : cache.findAll();
          break;
        case 'create':
          resp = cache.create(model);
          break;
        case 'update':
          resp = cache.update(model);
          break;
        case 'delete':
          resp = cache.destroy(model);
          break;
      }

      if (resp) options.success(resp);
      else options.error("Record not found.");

    }

  });

  return Collection;

});

