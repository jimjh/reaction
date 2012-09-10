/* ========================================================================
 * collection.js v0.0.1.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global _:true*/

// ## reaction-collection Module
define(['require', './config', './util'], function(require){

  'use strict';

  // Inserts a document into the collection.
  var insert = function(document) {
    this.items.concat(document);
    // TODO
  };

  // Removes a document from the collection.
  var remove = function(query) {
    // TODO
    this.items.remove(query);
  };

  // Creates a persistent collection.
  //
  //      // create a new collection with data from cache
  //      reaction.collection('ints');
  //      // create a new collection containing [1,2,3]
  //      reaction.collection('ints', [1,2,3]);
  //      // create a new collection containing an empty array.
  //      reaction.collection('ints', []);
  //
  // ### options
  // * `persist`:   set this to `false` to skip local storage (defaults to `true`).
  var constructor = function(name, items, options) {

    var that = {
      name: name,
      insert: insert,
      remove: remove
    };

    if (_.isUndefined(items)) {
      var cached = require('./cache')._get(name);
      if (!_.isUndefined(cached)) that.items = cached.items;
    } else {
      that.items = items;
      options = _.defaults(options || {}, {persist: true});
      if (options.persist) require('./cache')._add(that);
    }

    return that;

  };

  return constructor;

});
