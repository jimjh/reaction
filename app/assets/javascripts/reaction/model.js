/* ========================================================================
 * model.js v0.0.1
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://github.com/jimjh/reaction/blob/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global Backbone:true*/

// # reaction-model Module.
define(['reaction/sync', 'backbone'], function(sync){

  'use strict';

  // ## Reaction.Model
  // Extend this to provide your own models. Must provide `name`.
  var Model = Backbone.Model.extend({
    name: 'post',
    sync: sync
  });

  return Model;

});
