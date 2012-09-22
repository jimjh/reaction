//} TODO: how I should release this in the most compatible manner?

requirejs.config({
  shim: {
          'backbone': {
            deps: ['underscore'],
            exports: 'backbone'
          },
          'faye/client': {
            exports: 'faye'
          },
          'amplify': {
            deps: ['json2'],
            exports: 'amplify'
          },
          'json2': {
            exports: 'json2'
          }
        }
});

require(['reaction'], function(reaction) {
  Reaction = reaction;
  //} FIXME: temporary
  $(window).trigger('reaction_loaded');
});
