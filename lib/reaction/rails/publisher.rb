module Reaction

  module Rails

    # The +:reaction+ mime type is defined as +application/vnd.reaction.v1+.
    # A request may specify this format by either:
    # - appending a +.reaction+ suffix to the resource URI, or
    # - sending an +Accept+ HTTP header that includes +application/vnd.reaction.v1+
    #
    # Every client has a UUID (pseudo-unique) client id that is attached to
    # each request. Deltas are broadcast with this ID, so clients can disregard
    # changes originating from themselves.
    #
    # In addition, each session has a channel ID (if multiple tabs are open in
    # the same browser, then many clients share the same channel ID). This is
    # kept on the client's cookie.
    #
    # @example Publish an index of posts.
    #   class PostsController < ApplicationController
    #     include Reaction::Rails::Publisher
    #
    #     # use one of the following
    #
    #     def index
    #       @posts = Post.find_by_some_criteria
    #       react_with(@posts) and return if reaction?
    #     end
    #
    #     def index
    #       @posts = Post.find_by_some_criteria
    #       respond_with @posts
    #     end
    #
    #     def index
    #       @posts = Post.find_by_some_criteria
    #       respond_to do |format|
    #         format.reaction { render :reaction => @posts }
    #       end
    #     end
    #
    #   end
    module Publisher

      # Callback invoked when Publisher is included in a controller. Registers
      # response mime type for +:reaction+.
      # @return [void]
      def self.included(base)
        base.respond_to :reaction
        base.before_filter :filter_before_reaction
      end

      # Renders given resource in the reaction format.
      # @example
      #   react_with(@posts) and return if reaction?
      # @return [void]
      def react_with(resource)
        render :reaction => resource
      end

      # @example
      #   react_with(@posts) and return if reaction?
      # @return [Boolean] true if request format is +:reaction+.
      def reaction?
        request.format.reaction?
      end

      # Ensures that the user's session has a generated channel id.
      def filter_before_reaction
        cookies[:channel_id] = SecureRandom.uuid unless cookies.key? :channel_id
      end

      # Broadcasts the specified action to all subscribed clients.
      # @example
      #   broadcast create: @post
      # TODO: smarter broadcast w. auto detect
      # TODO: authorization
      # TODO: use an after filter?
      def broadcast(options)

        options.each do |action, delta|
          delta = Serializer.format_data delta.attributes,
            action: action,
            client_id: params[:client_id]
          Reaction.registry.each { |channel_id|
            channel = "/#{self.controller_name}/#{channel_id}"
            Reaction.bayeux.get_client.publish(channel, delta)
          }
        end

      end

    end

  end

end
