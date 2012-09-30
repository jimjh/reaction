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
    # In addition, when the client first makes a request to a controller that
    # includes Publisher, a channel ID and a signature is generated for the
    # client. Together, they allow the client to access a private channel. Note
    # that because these are stored in the cookie, multiple clients might share
    # the same channel ID (e.g. same app in multiple tabs.)
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

      # Ensures that the user's cookie has a generated channel id and
      # signature.
      def filter_before_reaction

        # Generates a new signature and stores it in the cookie/session.
        def generate
          cookies[:_r_channel_id], cookies[:_r_signature], session[:_r_secret] =
            Registry::Signature.generate ::Rails.application.config.secret_token
        end

        unless cookies.key? :_r_channel_id and cookies.key? :_r_signature
          generate
        else
          channel_id, signature, secret =
            cookies[:_r_channel_id], cookies[:_r_signature], session[:_r_secret]
          valid = Registry::Signature.validate signature,
            channel_id: channel_id,
            secret: secret,
            salt: ::Rails.application.config.secret_token
          generate unless valid
        end

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
            origin: params[:origin]
          Reaction.registry.each { |channel_id|
            channel = "/#{self.controller_name}/#{channel_id}"
            Reaction.bayeux.get_client.publish(channel, delta)
          }
        end

      end

    end

  end

end
