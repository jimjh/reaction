/* ========================================================================
 * model.js
 * http://github.com/jimjh/reaction
 * ========================================================================
 * Copyright (c) 2012 Carnegie Mellon University
 * License: https://raw.github.com/jimjh/reaction/master/LICENSE
 * ========================================================================
 */
/*jshint strict:true unused:true*/
/*global Backbone:true*/

// # reaction-model Module.
define(['reaction/sync', 'backbone'], function(sync){

  'use strict';

  // ## Reaction.Model
  var Model = Backbone.Model.extend({
    sync: sync
  });

  return Model;

});
