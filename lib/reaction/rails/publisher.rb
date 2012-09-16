module Reaction

  module Rails

    # The +:reaction+ mime type is defined as +application/vnd.reaction.v1+.
    # A request may specify this format by either:
    # - appending a +.reaction+ suffix to the resource URI, or
    # - sending an +Accept+ HTTP header that includes +application/vnd.reaction.v1+
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

      # Broadcasts the specified action to all subscribed clients.
      # @example
      #   broadcast create: @post
      # TODO: smarter broadcast w. auto detect
      # TODO: authorization
      # TODO: don't send to the client that initiated the change
      def broadcast(options)
        # TODO: complete for other actions
        if options.include? :create
          delta = Serializer.format_data(options[:create])
          Reaction.bayeux.get_client.publish('/' + self.controller_name, delta)
        end
      end

    end

  end

end
