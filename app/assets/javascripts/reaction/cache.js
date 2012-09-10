/* ========================================================================
 * cache.js v0.0.1.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global $:true _:true amplify:true*/

// # reaction-cache Module
// Uses amplify.js to simulate a write-through cache.
define(['./config', './util', 'faye/client', 'amplify'],
       function(config){

  'use strict';

  // Prefix for keys in the amplify store.
  var CACHE_KEY_PREFIX = 'reaction.cache.';

  // Schemas - predefined formats of server responses.
  var SCHEMA = {
    data: 'data'
  };

  // Generates cache key from collection name.
  var _key = function(collection) {
    return CACHE_KEY_PREFIX + collection;
  };

  // Checks if the collection exists in the cache.
  var has = function(collection) {
    if (_.isEmpty(collection)) return false;
    return !_.isUndefined(amplify.store(_key(collection)));
  };

  // Handles the first record set for a collection received from the server.
  //} TODO: check etags, cache control etc
  var _data_handler = function(collection, data){
    // Throws error if data has the wrong schema.
    _.assert(SCHEMA.data, data.type);
    //} TODO: insert instead of override?
    amplify.store(_key(collection), data.items);
  };

  // Sets the collection in the cache, with the given array of items.
  var set = function(collection, items) {
    // Throws an error if the collection name is undefined or empty.
    if (_.isEmpty(collection)) throw {error: 'collection name must not be empty.'};
    amplify.store(_key(collection), items);
    //} TODO: sync?
  };

  // Removes a collection from the cache.
  var unset = function(collection) {
    // Throws an error if the collection name is undefined or empty.
    if (_.isEmpty(collection)) throw {error: 'collection name must not be empty.'};
    amplify.store(_key(collection), null);
  };

  var insert = function(collection, doc) {
    if (_.isEmpty(collection)) throw {error: 'collection name must not be empty.'};
    var inserted = amplify.store(_key(collection)).concat(doc);
    amplify.store(_key(collection), inserted);
    //} TODO: sync?
  };

  // Subscribes to a published collection and keeps a cached copy of the records in
  // HTML5 local storage.
  var subscribe = function(collection, callback){

    // Throws error if `collection` is undefined or empty.
    if (_.isEmpty(collection)) throw {error: 'model must not be undefined or empty.'};

    var uri = _('{0}{1}.reaction').format(config.paths.root, collection);

    //} TODO: callback

    $.getJSON(uri)
      .success(_.curry(_data_handler, collection))
      .error(function(xhr, textStatus, errorThrown){
        // TODO: could be user error, or network
        _.log(xhr, textStatus, errorThrown);
      });

  };

  var get = function(collection) {
    if (_.isEmpty(collection)) throw {error: 'collection name must not be empty.'};
    return amplify.store(_key(collection));
  };

  return {
    subscribe: subscribe,
    has: has,
    insert: insert,
    get: get,
    set: set,
    unset: unset
  };

});

