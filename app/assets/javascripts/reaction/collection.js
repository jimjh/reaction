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
    initialize: function(name) {

      // Throws error if `name` is undefined or empty.
      if (_.isEmpty(name)) throw {error: 'name must not be undefined or empty.'};

      this.name = name;
      this.cache = new Cache(this);

    },

    // Overrides Backbone.sync to use Reaction.Cache.
    sync: sync

  });

  return Collection;

});

