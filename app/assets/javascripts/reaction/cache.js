/* ========================================================================
 * cache.js v0.0.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global _:true $:true amplify:true*/

// ## reaction-cache Module
define(['reaction/config', 'reaction/util', 'amplify'], function(config) {

  'use strict';

  // Prefix for keys in the amplify store.
  var CACHE_KEY_PREFIX = 'reaction.cache.';

  // Schemas - predefined formats of server responses.
  var SCHEMA = {
    data: 'data'
  };

  // Generates cache key from name.
  var key = function(name) {
    return CACHE_KEY_PREFIX + name;
  };

  // Creates a new cache that is sync'ed with a Rails model of the same name.
  // Options:
  // * `onData`: invoked when the data is ready.
  var Cache = function(name, options) {

    // Throws error if `name` is undefined or empty.
    if (_.isEmpty(name)) throw {error: 'model must not be undefined or empty.'};

    // Ensure that the options dictionary is valid.
    options = _.defaults(options || {}, {
      onData: function(){}
    });

    this.uri = _('{0}{1}.reaction').format(config.paths.root, name);
    this.key = key(name);
    this.onData = options.onData;

    _.defer(_.bind(this._fetch, this));

  };

  // Fetches the default set of items from the server.
  //} TODO: Check etags, cache control etc. Don't need to fetch all the time.
  Cache.prototype._fetch = function() {

    $.ajax({
      url: this.uri,
      dataType: 'json',
      success: _.bind(this._onFetch, this),
      error: function(xhr, textStatus) {
        this.tryCount = this.tryCount || 0;
        this.tryCount++;
        if (this.tryCount <= 3) {
          _.log("retrying");
          $.ajax(this);
          return;
        }
        _.logf("Unable to retrieve data from {0}. Status was {1}", this.url, textStatus);
      }
    });

  };

  // Validates the format of the received data and saves it in HTML5 local
  // storage. Invoked when the #_fetch() succeeds.
  Cache.prototype._onFetch = function(data){
    _.assert(SCHEMA.data, data.type);
    amplify.store(this.key, data.items);
    this.onData(data.items);
  };

  return Cache;


});
