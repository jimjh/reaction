module Reaction

  module Rails

    # Rails engine for serving javascript assets.
    class Engine < ::Rails::Engine
      initializer 'static_assets.load_static_assets',
        :group => :all do |app|
        # FIXME: namespacing
        # When I release the gem, all my javascript files should be compiled
        # and minified in a single file that the user can use via the asset
        # pipeline. Vendor scripts e.g. underscore.js, backbone.js, jquery should
        # not be included, but should be specified as dependencies.
        app.middleware.use ::ActionDispatch::Static, File.join(Reaction.paths.root, '..', 'app')
        app.middleware.use ::ActionDispatch::Static, File.join(Reaction.paths.root, '..', 'vendor')
      end
    end

  end

end
