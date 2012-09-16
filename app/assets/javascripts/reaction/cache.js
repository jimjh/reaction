/* ========================================================================
 * cache.js v0.0.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global _:true $:true amplify:true Faye:true*/

//} TODO: propagate errors to user.
//} TODO: refactor this file - too much duplicate code.

// ## reaction-cache Module
define(['reaction/config', 'reaction/identifier', 'reaction/util', 'amplify', 'faye/client'],
       function(config, identifier) {

  'use strict';

  // Prefix for keys in the amplify store.
  var CACHE_KEY_PREFIX = 'reaction.cache.';

  // Schemas - predefined formats of server responses.
  var SCHEMA = {
    data: 'data',
    datum: 'datum'
  };

  // Text status from jqXHR that warrant a retry.
  var RETRY_STATUSES = ["timeout"];

  // Generates cache key from collection name.
  var key = function(name) {
    return CACHE_KEY_PREFIX + name;
  };

  // Used as a XHR error callback to force retry.
  //
  //      $.ajax({error: retry});
  var retry = function(xhr, textStatus){
    this.tryCount = this.tryCount || 0;
    this.tryCount++;
    if (_.include(RETRY_STATUSES, textStatus) && this.tryCount <= 3) {
      _.logf("Data retrieveal from {0} failed. Retrying.", this.url);
      $.ajax(this);
      return;
    }
    _.logf("Unable to retrieve data from {0}. Status was {1}", this.url, textStatus);
  };

  // Creates a new cache that is sync'ed with a Rails model of the same name.
  // Options:
  // * `onData`: invoked when the data is ready.
  var Cache = function(collection, options) {

    // Throws error if `collection` is undefined.
    if (_.isUndefined(collection)) throw {error: 'collection is required.'};

    // Ensure that the options dictionary is valid.
    options = _.defaults(options || {}, {
      onData: function(){}
    });

    this.collection = collection;
    this.uri = _('{0}{1}').format(config.paths.root, collection.name);
    this.key = key(collection.name);
    this.onData = options.onData;

    // Fetch the default set of records.
    _.defer(_.bind(this._fetch, this));

  };

  // Fetches the default set of items from the server.
  //} TODO: Check etags, cache control etc. Don't need to fetch all the time.
  Cache.prototype._fetch = function() {
    $.ajax({
      url: this.uri + '.reaction',
      dataType: 'json',
      success: _.bind(this._onFetch, this),
      error: function(xhr, textStatus){ retry.apply(this, [xhr, textStatus]); }
    });
  };

  // Validates the format of the received data and saves it in HTML5 local
  // storage. Invoked when #_fetch() succeeds.
  Cache.prototype._onFetch = function(data) {
    _.assert(SCHEMA.data, data.type);
    this._storeList(data.items);
    this.onData(data.items);
    this._subscribe();
  };

  // Subscribe to Faye channel for changes.
  // FIXME: probably should use client-specific channels.
  Cache.prototype._subscribe = function() {
    this.client = new Faye.Client(config.paths.bayeux);
    this.client.addExtension(identifier);
    var endpoint = _('/{0}/{1}').format(this.collection.name, _.cookie('channel_id'));
    this.client.subscribe(endpoint, _.bind(this._onDelta, this));
  };

  // Invoked on delta from server.
  Cache.prototype._onDelta = function(message) {

    // TODO: complete
    var delta = $.parseJSON(message);
    switch (delta.type) {
      case SCHEMA.datum:
        // FIXME: this duplicates _onCreate
        this._storeItem(delta.item);
        var model = this.collection.get(delta.item.id);
        _.log(delta.item.id);
        _.log(model);
        if (model) {
          model.set(delta.item);
        } else {
          this.collection.add(new this.collection.model(delta.item));
        }
        break;
      case SCHEMA.data:
        break;
    }

  };

  // Makes a POST request to create the model on the server, and then saves a
  // copy of it on local storage.
  Cache.prototype.create = function(model, options) {

    // Prepare data in Rails format.
    var data = {};
    data[model.name] = model.attributes;

    $.ajax({
      url: this.uri + '.reaction',
      type: 'POST',
      dataType: 'json',
      data: data,
      success: _.bind(this._onCreate, this, model, options.success),
      error: options.error
    });

  };

  // Validates the format of the received data and saves it in a HTML5 local
  // storage. Invoked when #create() succeeds.
  Cache.prototype._onCreate = function(model, success, resp, status, xhr) {
    _.assert(SCHEMA.datum, resp.type);
    this._storeItem(resp.item);
    success(resp.item, status, xhr);
  };

  // Makes a DELETE request to delete the model on the server, and then updates
  // local storage.
  Cache.prototype.destroy = function(model, options) {

    $.ajax({
      url: _('{0}/{1}.reaction').format(this.uri, model.id),
      type: 'DELETE',
      dataType: 'json',
      success: _.bind(this._onDestroy, this, model, options.success),
      error: options.error
    });

  };

  // Validates the format of the received data and saves it in a HTML5 local
  // storage. Invoked when #destroy succeeds.
  Cache.prototype._onDestroy = function(model, success, resp) {
    // TODO:
    _.log('destroyed');
    _.log(resp);
    success(resp);
  };

  // Stores the given list into HTML5 local storage.
  Cache.prototype._storeList = function(list) {
    // map id to item
    var dict = {};
    _.each(list, function(item) { dict[item.id] = item; });
    amplify.store(this.key, dict);
  };

  // Stores the given item into HTML5 local storage.
  Cache.prototype._storeItem = function(item) {
    var dict = amplify.store(this.key);
    dict[item.id] = item;
    amplify.store(this.key, dict);
  };

  // Finds the model from its cache, or from the server.
  Cache.prototype.find = function(model, options) {

    var dict = amplify.store(this.key);
    options.success(dict[model.id]);

    // TODO: get from server

  };

  return Cache;


});
