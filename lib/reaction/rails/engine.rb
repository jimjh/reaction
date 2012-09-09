module Reaction

  module Rails

    # Rails engine for serving javascript assets.
    class Engine < ::Rails::Engine
      initializer 'static_assets.load_static_assets',
        :group => :all do |app|
        app.middleware.use ::ActionDispatch::Static, File.join(Reaction.paths.root, '..', 'app')
      end
    end

  end

end
