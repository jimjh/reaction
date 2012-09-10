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

// ## reaction-cache Module
define(['require', './config', './collection', './util', 'faye/client', 'amplify'],
       function(require, config, collection){

  'use strict';

  // Prefix for keys in the amplify store.
  var CACHE_KEY_PREFIX = 'reaction.cache.';
  var META_MODEL= 'meta';
  var meta_collection = null;

  // Schemas - predefined formats of server responses.
  var SCHEMA = {
    data: 'data'
  };

  // Generates cache key from model.
  var _key = function(model) {
    return CACHE_KEY_PREFIX + model;
  };

  var initialized = false;

  // Initializes the cache.
  var _init = function(){

    if (initialized) {
      _.log('Cache had already been initialized.');
      return;
    }

    // Ensure that the meta collection exists.
    if (_.isUndefined(amplify.store(_key(META_MODEL)))){
      meta_collection = collection(META_MODEL, [], { persist: false });
      amplify.store(_key(META_MODEL), meta_collection);
    } else {
      meta_collection = collection(META_MODEL);
    }

    initialized = true;

  };

  // Handles the first record set for a model.
  // TODO: check etags, cache control etc
  var _data_handler = function(model, data){
    // Throws error if data has the wrong schema.
    _.assert(SCHEMA.data, data.type);
    collection(model, data.items);  // autosaves
  };

  // Adds a collection to the cache.
  var _add = function(collection) {
    amplify.store(_key(collection.name), collection);
    meta_collection.insert(collection.name);
  };

  // Retrieves a collection from the cache.
  var _get = function(model) {
    return amplify.store(_key(model));
  };

  // Removes a collection from the cache.
  var _remove = function(model) {
    amplify.store(_key(model), null);
    meta_collection.remove({name: model});
  };

  // Unsubscribes from the specified model and removes it from the cache.
  var unsubscribe = function(model){

    // Throws error if `model` is undefined or empty.
    if (_.isUndefined(model) || _.isEmpty(model)) {
      throw {error: 'model must not be undefined or empty.'};
    }

    _remove(model);

  };

  // Subscribes to a published model and keeps a cached copy of the records in
  // HTML5 local storage.
  var subscribe = function(model){

    // Throws error if `model` is undefined or empty.
    if (_.isUndefined(model) || _.isEmpty(model)) {
      throw {error: 'model must not be undefined or empty.'};
    }

    var uri = _('{0}{1}.reaction').format(config.paths.root, model);

    $.getJSON(uri)
      .success(_.curry(_data_handler, model))
      .error(function(xhr, textStatus, errorThrown){
        // TODO: could be user error, or network
        _.log(xhr, textStatus, errorThrown);
      });

  };

  return {
    subscribe: subscribe,
    unsubscribe: unsubscribe,
    _add: _add,
    _get: _get,
    _init: _init
  };

});

