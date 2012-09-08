require 'action_controller/metal/responder'
require 'action_controller/metal/renderers'

# Monkey-patched Responder class
class ActionController::Responder
  # Converts resource to the reaction format.
  def to_reaction
    controller.render :reaction => resource
  end
end

module Reaction
  module Rails

    ActionController::Renderers.add :reaction do |obj, options|
      self.response.content_type = Mime::REACTION
      # serialize into our format
      self.response_body = Serializer.format_data(self, obj)
    end

    # Serializer for Rails-Reaction.
    module Serializer
      class << self

        # Prepares JSON in reaction data format.
        # @param [ActionController] controller        rails controller, will be
        #                                             used for name of collection
        # @param [Enumerable] obj                     some collection of
        #                                             objects to publish
        # @return [String] formatted json
        def format_data(controller, obj)
          {type: 'data',
           collection: controller.controller_name.classify,
           items: obj}.to_json
        end

      end
    end

  end
end
