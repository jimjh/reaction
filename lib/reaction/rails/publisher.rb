module Reaction

  module Rails

    # Publisher handles responses that use the +:reaction+ format.
    # The +:reaction+ mime type is defined as +application/vnd.reaction.v1+.
    # A request may specify this format by either:
    # - appending a +.reaction+ suffix to the resource URI, or
    # - sending an +Accept+ HTTP header that includes +application/vnd.reaction.v1+
    #
    # == Origin
    # Every client has a pseudo-unique origin id that is attached to each XHR
    # request. Deltas broadcast by Publisher carry this ID with them, so
    # clients can disregard changes originating from themselves. For more
    # details, refer to the +reaction-identifier+ module in the javascript
    # library.
    #
    # == Authentication
    # When the client makes a +#fetch()+ call to the controller to retrieve an
    # index of records, Publisher checks the session for a few things:
    # - If the session contains a +channel_id+, a new access token is generated
    #   for this channel and sent along with the response.
    # - Otherwise, a new +channel_id+ and access token pair is generated and
    #   sent along with the response.
    #
    # The client should use the access token to subscribe to the private
    # channel and listen for updates. Note that because the +channel_id+ is
    # stored in the session, it's reset when the session is invalidated,
    # preventing channel fixation attacks.
    #
    # === Generating Channel IDs
    # Publisher will try to get a channel ID in the following order:
    # 1. If the controller responds to +:reaction_channel+ method, then it
    #    is invoked to generate an ID.
    # 1. If the controller responds to +:current_user+ and the returned object
    #    responds to +:id+, then the user's ID is used as the channel ID.
    # 1. If all else fails, then a unique ID is generated via +SecureRandom#uuid+.
    #
    # === Generating Access Tokens
    # The Rails salt is used to generate a secret token.
    #     SHA256(channel_id + date + user-agent + csrf + salt)
    #
    # A 'Date' header will be added to the response. The client should include
    # this in the subscription request.
    #
    # === Validating Access Tokens
    # When Faye receives a connection request, the access token provided by the
    # client will be validated using:
    #     SHA256(channel_id + date + user_agent + csrf + salt)
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

      # HTTP Header for channel ID
      CHANNEL_HEADER = 'X-Reaction-Channel'

      # HTTP Header for access token
      TOKEN_HEADER = 'X-Reaction-Token'

      # HTTP Header for date
      DATE_HEADER = 'Date'

      # HTTP request header for reaction request type.
      X_REQUEST = 'HTTP_X_REACTION_REQUEST'

      # Callback invoked when Publisher is included in a controller. Registers
      # response mime type for +:reaction+, and adds +:ensure_channel+ as a
      # before_filter for +:index+.
      # @return [void]
      def self.included(base)
        base.respond_to :reaction
        base.before_filter :ensure_channel, only: [:index]
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

      # @return [Boolean] true iff reaction request type is 'sync'
      def reaction_sync?
        'sync' == env[X_REQUEST]
      end

      # Ensures that the user's session has a channel ID. If a channel ID is
      # found, generates a new token; otherwise, generates a new channel ID and
      # token pair.
      #
      # If the parameter +id_only+ is present, renders immediately and avoids
      # controller action.
      # @return [void]
      def ensure_channel

        session[:_r_channel] ||= Helpers.generate_channel(self)
        date = Time.now.to_i.to_s
        token = Reaction.client.access_token \
          channel_id: session[:_r_channel],
          date: date,
          user_agent: request.env['HTTP_USER_AGENT'] || '',
          csrf: request.env['HTTP_X_CSRF_TOKEN'] || ''

        response.headers.merge! \
          CHANNEL_HEADER => session[:_r_channel],
          TOKEN_HEADER => token,
          DATE_HEADER => date

        # halt immediately if it's a channel request
        react_with([]) if 'channel' == env[X_REQUEST]

      end

      # Broadcasts the specified action to all subscribed clients. The options
      # parameter is a hash of actions to data items.
      #
      # @example
      #   broadcast create: @post
      #   broadcast create: @posts
      #
      # @option opts :to      can be a regular expression or an array, defaults
      #                       to all
      # @option opts :except  can be a regular expression or an array,
      #                       defaults to none
      # @return [void]
      def broadcast(opts)

        filter = {     to:  opts.delete(:to),
                   except:  opts.delete(:except) }

        opts.each do |action, delta|
          delta = Serializer.format_data delta.attributes,
            action: action,
            origin: params[:origin]
          Reaction.client.broadcast(controller_name, delta, filter)
        end

      end

      # Helper methods for Publisher that should not be exposed to the
      # including controller.
      module Helpers

        class << self

          # Generates a channel id. Refer to {Reaction::Rails::Publisher} for
          # the algorithm.
          # @param [Rails::ActionController] ctrl   the controller that includes
          #                                         Publisher
          # @return [String] channel ID
          def generate_channel(ctrl)
            return ctrl.reaction_channel if ctrl.respond_to? :reaction_channel
            return ctrl.current_user.id if ctrl.respond_to?(:current_user) &&
              ctrl.current_user.respond_to?(:id)
            return SecureRandom.uuid
          end

        end

      end

    end

  end

end
