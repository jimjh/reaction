var requirejs = require('requirejs');

var config = {
    baseUrl: 'assets',
    name: 'almond',
    out: 'app/assets/javascripts/reaction.js',
    include: 'main',
    wrap: true,
};

requirejs.optimize(config);
