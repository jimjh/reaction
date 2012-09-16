require 'action_controller/metal/responder'
require 'action_controller/metal/renderers'

# Monkey-patched Responder class.
class ActionController::Responder
  # @return [String] JSON representation of resource in reaction format.
  def to_reaction
    controller.render :reaction => resource
  end
end

module Reaction
  module Rails

    ActionController::Renderers.add :reaction do |obj, options|
      self.response.content_type = Mime::REACTION
      # serialize into the reaction format
      if obj.is_a? ActiveRecord::Base and obj.errors.any?
        self.response.status = :bad_request
      end
      self.response_body = Serializer.format_data(obj)
    end

    # Serializer for Rails-Reaction.
    module Serializer
      class << self

        # Prepares JSON in reaction data format
        # @param [Enumerable] obj                 some collection of
        #                                         objects to publish
        # @return [String] formatted json
        def format_data(obj)
          if obj.is_a? Enumerable
            format_array(obj)
          else
            format_obj(obj)
          end
        end

        private

        def format_obj(obj)
          return 'null' if obj.nil?
          response = { type: 'datum', item: obj }
          response[:errors] = obj.errors if obj.errors.any?
          response.to_json
        end

        def format_array(arr)
          { type: 'data', items: arr }.to_json
        end

      end
    end

  end
end
