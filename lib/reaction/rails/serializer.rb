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

      self.response_body =
        (self.reaction_sync?) ? Serializer.format_diff(obj, params) : Serializer.format_data(obj)

    end

    # Serializer for Rails-Reaction.
    module Serializer
      class << self

        # Prepares JSON in reaction data format.
        # @param [Enumerable|Hash] obj    some array of objects to publish
        # @return [String] formatted json
        def format_data(obj, opts = {})
          case obj
          when Array
            format_array(obj, opts)
          else
            format_obj(obj, opts)
          end.to_json
        end

        # Prepares JSON in reaction data format and compares new results
        # against cached results on client.
        # @param [Enumerable] arr         some array of objects to send
        # @param [Hash]       params      HTTP GET parameters
        # @return [String] formatted json
        def format_diff(arr, params)
          cached = params[:cached] || {}
          sync = {type: 'sync', deltas: []}
          arr.each do |new|
            id = new[:id].to_s
            sync[:deltas] << if cached.include? id
              next if cached.delete(id).to_f >= new[:updated_at].to_f
              update_d new
            else
              create_d new
            end
          end
          cached.each { |missing| sync[:deltas] << destroy_d(id: missing[0]) }
          sync.to_json
        end

        private

        def format_obj(obj, opts)
          return base_d(nil) if obj.nil?
          response = base_d(obj, opts)
          response[:errors] = obj.errors if obj.respond_to? :errors and obj.errors.any?
          response
        end

        def format_array(arr, opts)
          {type: 'data', items: arr}.merge(opts)
        end

        def destroy_d(item)
          base_d item, action: 'destroy'
        end

        def create_d(item)
          base_d item, action: 'create'
        end

        def update_d(item)
          base_d item, action: 'update'
        end

        def base_d(item, opts={})
          # patch for to_json to give more precision to Time
          if not item.nil? and item[:updated_at]
            item = item.dup if item.frozen?
            item[:updated_at] = item[:updated_at].to_f
          end
          {type: 'datum', item: item}.merge opts
        end

      end
    end

  end
end
