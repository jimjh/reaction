Reaction = {};
_.extend(Reaction, Backbone.Events);

require(['reaction'], function(reaction) {
  _.extend(Reaction, reaction);
  Reaction.trigger('ready');
});
