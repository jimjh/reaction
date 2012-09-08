module Reaction

  module Rails

    # @example Publish an index of posts.
    #   class PostsController < ApplicationController
    #     extend Reaction::Rails::Publisher
    #
    #     # use one of the following
    #
    #     def index
    #       @posts = ...
    #       react_with @posts and return if reaction?
    #     end
    #
    #     def index
    #       @posts = ...
    #       respond_with @posts
    #     end
    #
    #     def index
    #       @posts = ...
    #       respond_to do |format|
    #         format.reaction { render :reaction => @posts }
    #       end
    #     end
    #
    #   end
    module Publisher

      # Registers response mime type.
      def self.included(base)
        base.respond_to :reaction
      end

      # Renders given resource in the reaction format.
      # @return [String] response body
      def react_with(resource)
        render :reaction => resource
      end

      # @return [Boolean] true if request format is reaction.
      def reaction?
        request.format.reaction?
      end

    end

  end

end
