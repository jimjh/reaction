var requirejs = require('requirejs'),
    path      = require('path'),
    sinon     = require('sinon');

require('sinon-mocha').enhance(sinon);

const APP_PATH = path.normalize(__dirname + '/../assets/');
const VENDOR_PATH = path.normalize(__dirname + '/../vendor/assets/javascripts/reaction/');

requirejs.config({
  baseUrl: APP_PATH,
  paths: {
    'underscore': VENDOR_PATH + 'underscore'
  },
  shim: {
    'backbone': {
      deps: ['underscore'],
      exports: 'backbone'
    }
  },
  nodeRequire: require
});

module.exports = {require: requirejs, sinon: sinon};
