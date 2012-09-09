module Reaction

  module Rails

    # Rails engine for serving javascript assets.
    class Engine < ::Rails::Engine
      initializer 'static_assets.load_static_assets' do |app|
        app.middleware.use ::ActionDispatch::Static, "#{Reaction.paths.root}/reaction/vendor"
      end
    end

  end

end
