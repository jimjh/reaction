/* ========================================================================
 * cache.js
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://raw.github.com/jimjh/reaction/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global _:true $:true amplify:true Faye:true*/

// ## reaction-cache Module
define(['./config', './names', './auth', './util', 'amplify', 'faye/client'],
       function(config, names, auth) {

  'use strict';

  // Prefix for keys in the amplify store.
  var CACHE_KEY_PREFIX = 'reaction.cache.';

  // Schemas - predefined formats of server responses.
  var SCHEMA = {
    data: 'data',
    datum: 'datum',
    sync: 'sync'
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
  var retry = function(xhr, textStatus) {
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

  // Fetches entries from the cache, and makes an asynchronous request to the
  // server for updates.
  //
  // 1. Return whatever is in the cache
  // 1. AJAX call to Controller#index to get channel ID
  // 1. Subscribe to channel
  // 1. AJAX call to Controller#index to get changes since last sync
  //
  // The trick is to subscribe before we sync, which ensures that every delta
  // is received at least once (if we did it the other way, deltas could come
  // in between sync and subscribe.)
  Cache.prototype.fetch = function(model, options) {

    //} return whatever is in cache
    options.success(_.values(this._readDict()), 'success');

    //} get channel ID
    options.success =  _.bind(this._onFetch, this, options);
    options.headers = options.headers || {};
    options.headers[names.headers.request] = 'channel';

    //} TODO: error handling and retry
    this._ajax(options);

  };

  // Invoked after the ajax call in `#fetch()` succeeds. Subscribes for updates
  // and sends a sync request to the server with the IDs and timestamps of
  // records in the cache.
  Cache.prototype._onFetch = function(options, resp, status, xhr) {

    //} subscribe to faye channel
    this._subscribe(xhr);

    //} prepare cached data for server diff
    var cached = {};
    _.each(this._readDict(), function(item, id) {
      cached[id] = item.updated_at;
    });
    _.defaults(options.data, { cached: cached });

    var onDelta = _.bind(this._onDelta, this);
    options.success = function(resp) {
      _.assert(SCHEMA.sync, resp.type);
      _.each(resp.deltas, onDelta);
    };

    options.headers[names.headers.request] = 'sync';
    this._ajax(options);

  };

  // Subscribe to Faye channel for changes.
  Cache.prototype._subscribe = function(xhr) {
    var channel = xhr.getResponseHeader(names.headers.channel);
    this.client = new Faye.Client(config.paths.bayeux);
    this.client.addExtension(auth({
      token: xhr.getResponseHeader(names.headers.token),
      date: xhr.getResponseHeader(names.headers.date)
    }));
    var endpoint = _('/{0}/{1}').format(this.collection.controller_name, channel);
    this.client.subscribe(endpoint, _.bind(this._onDelta, this));
  };

  // Responds to changes on server and propagates them to the client.
  Cache.prototype._onDelta = function(delta) {

    //} `instanceof String` doesn't always work. Lame.
    if (typeof delta === "string") delta = $.parseJSON(delta);
    var that = this;

    // Ignore deltas from this client.
    if (config.id == delta.origin) return;

    switch (delta.action) {
      case 'create':
        this._onCreate(null, function(item) {
          that.collection.add(new that.collection.model(item));
        }, delta);
        break;
      case 'update':
        this._onUpdate(null, function(item) {
          that.collection.get(item.id).set(item);
        }, delta);
        break;
      case 'destroy':
        this._onDestroy(null, function(item) {
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

  // Retrieves dictionary of items from HTML5 local storage.
  Cache.prototype._readDict = function() {
    var dict = amplify.store(this.key);
    if (_.isEmpty(dict)) return {};
    return dict;
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
    var dict = amplify.store(this.key) || {};
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
