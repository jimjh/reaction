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

// # reaction-collection Module
//} TODO: need to somehow remember which collections are synced and which
//  aren't
define(['./cache', './config', './util'], function(cache){

  'use strict';

  var insert = function(doc) {
    cache.insert(this.name, doc);
  };

  var remove = function() {
    _.log('remove!');
  };

  var find = function() {
    // TODO
    return cache.get(this.name);
  };

  var _add_methods = function(obj) {
    obj.insert = insert;
    obj.remove = remove;
    obj.find = find;
    return obj;
  };

  // The 'meta' collection keeps an array of existing collections in the local
  // storage. It's initialized on startup.
  var meta_collection = null;
  if (!cache.has('meta')) cache.set('meta', []);
  meta_collection = _add_methods({ name: 'meta' });

  // ## Creating a persistent collection
  //
  // ### Examples
  //     // create a new collection with data from cache/server
  //     reaction.collection('posts');
  //     // create a new collection containing [{..},{..},{..}]
  //     reaction.collection('posts', [{..}, {..}, {..}]);
  //     // create a new collection containing an empty array.
  //     reaction.collection('ints', []);
  var constructor = function(name, items, options) {

    var that = _add_methods({ name: name });

    // ### Options
    // * `onData`: A callback function that is executed when data is received.
    //             This will be invoked immediately if `items` is specified.
    //             Optional.
    options = _.defaults(options || {}, {
      onData: function(){}
    });

    if (_.isUndefined(items)) {
      // If the second argument (`items`) is not specified, the collection is
      // automatically subscribed to a published model of the same name.
      //} TODO: need some way to callback when data is received.
      cache.subscribe(name, options.onData);
    } else {
      // Otherwise, `items` is persisted in local storage. An error is thrown
      // if `items` is not an array.
      if (!_.isArray(items)) throw {error: 'items must be an array.'};
      cache.set(name, items);
      _.defer(options.onData);
    }

    meta_collection.insert({name: name});

    return that;

  };

  return constructor;

});
