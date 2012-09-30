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

// ## reaction-cache Module
define(['./config', './identifier', './util', 'amplify', 'faye/client'],
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
  var Cache = function(collection) {

    // Throws error if `collection` is undefined.
    if (_.isUndefined(collection)) throw {error: 'collection is required.'};

    this.collection = collection;
    this.uri = _('{0}{1}').format(config.paths.root, collection.controller_name);
    this.key = key(collection.controller_name);
    this._subscribe();

  };

  // Makes an AJAX request using the given options.
  Cache.prototype._ajax = function(options) {
    options.data = options.data || {};
    options.data.origin = config.id;
    _.defaults(options, {
      url: this.uri + '.reaction',
      dataType: 'json'
    });
    $.ajax(options);
  };

  // Fetches the default set of items from the server.
  //} TODO: Check etags, cache control etc. Don't need to fetch all the time.
  Cache.prototype.fetch = function(model, options) {
    options.success =  _.bind(this._onFetch, this, model, options.success);
    this._ajax(options);
  };

  // Validates the format of the received data and saves it in HTML5 local
  // storage. Invoked when #_fetch() succeeds.
  Cache.prototype._onFetch = function(model, success, resp, status, xhr) {
    _.assert(SCHEMA.data, resp.type);
    this._storeList(resp.items);
    success(resp.items, status, xhr);
  };

  // Subscribe to Faye channel for changes. Uses one channel for each client.
  Cache.prototype._subscribe = function() {
    this.client = new Faye.Client(config.paths.bayeux);
    this.client.addExtension(identifier);
    var endpoint = _('/{0}/{1}').format(
      this.collection.controller_name,
      _.cookie(config.cookies.channelId)
    );
    this.client.subscribe(endpoint, _.bind(this._onDelta, this));
  };

  // Responds to changes on server and propagates them to the client.
  Cache.prototype._onDelta = function(message) {

    var delta = $.parseJSON(message);
    var that = this;

    // Ignore invalid deltas or deltas from this client.
    if (_.isEmpty(delta.origin) || config.id == delta.origin) return;

    switch (delta.action) {
      case 'create':
        that._onCreate(null, function(item) {
          that.collection.add(new that.collection.model(item));
        }, delta);
        break;
      case 'update':
        that._onUpdate(null, function(item) {
          that.collection.get(item.id).set(item);
        }, delta);
        break;
      case 'destroy':
        that._onDestroy(null, function(item) {
          that.collection.remove(item.id);
        }, delta);
        break;
    }

  };

  // Makes a POST request to create the model on the server, and then saves a
  // copy of it on local storage.
  Cache.prototype.create = function(model, options) {

    // Prepare data in Rails format.
    var data = {};
    data[this.collection.model_name] = model.attributes;

    // Prepare options dict, make AJAX call.
    _.defaults(options, { type: 'POST', data: data });
    options.success = _.bind(this._onCreate, this, model, options.success);
    this._ajax(options);

  };

  // Validates the format of the received data and saves it in a HTML5 local
  // storage. Invoked when #create() succeeds.
  Cache.prototype._onCreate = function(model, success, resp, status, xhr) {
    _.assert(SCHEMA.datum, resp.type);
    this._storeItem(resp.item);
    success(resp.item, status, xhr);
  };

  // Makes a PUT request to update a model on the server, and then updates the
  // copy in the local storage.
  Cache.prototype.update = function(model, options) {

    var data = {};
    data[this.collection.model_name] = model.attributes;

    _.defaults(options, {
      type: 'PUT',
      url: _('{0}/{1}.reaction').format(this.uri, model.id),
      data: data
    });
    options.success = _.bind(this._onUpdate, this, model, options.success);
    this._ajax(options);

  };

  // Validates format of the received data and saves it in a HTML5 local
  // storage. Invoked when `update()` succeeds.
  Cache.prototype._onUpdate = function(model, success, resp, status, xhr) {
    _.assert(SCHEMA.datum, resp.type);
    this._storeItem(resp.item);
    success(resp.item, status, xhr);
  };

  // Makes a DELETE request to delete the model on the server, and then updates
  // local storage.
  Cache.prototype.destroy = function(model, options) {

    _.defaults(options, {
      type: 'DELETE',
      url: _('{0}/{1}.reaction').format(this.uri, model.id)
    });
    options.success = _.bind(this._onDestroy, this, model, options.success);
    this._ajax(options);

  };

  // Validates the format of the received data and saves it in a HTML5 local
  // storage. Invoked when `destroy()` succeeds.
  Cache.prototype._onDestroy = function(model, success, resp, status, xhr) {
    _.assert(SCHEMA.datum, resp.type);
    this._removeItem(resp.item);
    success(resp.item, status, xhr);
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

  // Removes the given item from the HTML5 local storage.
  Cache.prototype._removeItem = function(item) {
    var dict = amplify.store(this.key);
    delete dict[item.id];
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
