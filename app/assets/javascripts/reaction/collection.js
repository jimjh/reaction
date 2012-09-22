/* ========================================================================
 * collection.js v0.0.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global _:true Backbone:true */

// # reaction-collection Module
// Usage:
//
//      var collection = new Reaction.Collection({
//        controller_name: 'posts,
//        model_name: 'post
//      });
//
//      collection.bind(..., ...);
//
//      collection.fetch(); // fires the add events
define(['reaction/cache', 'reaction/model', 'reaction/sync', 'reaction/util', 'backbone'],
       function(Cache, Model, sync) {

  'use strict';

  // ## Reaction.Collection
  // Uses `Reaction.Model` by default.
  var Collection = Backbone.Collection.extend({

    model: Model,

    // Creates a new collection tied to a Rails model of the same name.
    initialize: function(opts) {

      // Throws error if opts is empty.
      if (_.isEmpty(opts)) _.fatal('Opts is required.');

      // Throws error if `controller_name` or `model_name` is undefined or empty.
      if (_.isEmpty(opts.controller_name)) _.fatal('Controller name must not be undefined or empty.');
      if (_.isEmpty(opts.model_name)) _.fatal('Model name must not be undefined or empty.');

      this.controller_name = opts.controller_name;
      this.model_name = opts.model_name;
      this.cache = new Cache(this);

    },

    // Overrides Backbone.sync to use Reaction.Cache.
    sync: sync

  });

  return Collection;

});

