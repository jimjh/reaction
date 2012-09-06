require 'action_controller/metal/responder'
require 'action_controller/metal/renderers'

# Monkey-patched Responder class
class ActionController::Responder
  # Converts resource to the reaction format.
  def to_reaction
    controller.render :json => resource.to_json
  end
end

module Reaction
  module Rails
    ActionController::Renderers.add :reaction do |obj, options|
      render({json: obj.to_json}.merge options)
    end
  end
end
