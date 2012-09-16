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
define(['reaction/cache', 'reaction/model', 'reaction/sync', 'backbone'],
       function(Cache, Model, sync) {

  'use strict';

  // ## Reaction.Collection
  // Uses `Reaction.Model` by default.
  var Collection = Backbone.Collection.extend({

    model: Model,

    // Creates a new collection tied to a Rails model of the same name.
    // Options:
    // * `onReady`: invoked when the DOM has been fully loaded and the data is
    //              ready. This can't be an event, because there is no
    //              guarantee that the handler will be registered before the
    //              event is fired. Takes an `events` parameter.
    //}             XXX: maybe this can be a parameter on its own.
    initialize: function(name, options) {

      // Throws error if `name` is undefined or empty.
      if (_.isEmpty(name)) throw {error: 'name must not be undefined or empty.'};

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

      this.cache = new Cache(this, options);

    },

    // Overrides Backbone.sync to use Reaction.Cache.
    sync: sync

  });

  return Collection;

});

