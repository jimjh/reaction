require 'reaction/rails'

DummyRails::Application.routes.draw do

  mount_reaction at: '/reaction'

end
