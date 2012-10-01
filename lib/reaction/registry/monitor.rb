module Reaction

  # --
  # XXX: BAD CODE.
  # * Channel ID is confusing, because we have faye channels, and then reaction's
  #   channel IDs.
  class Registry

    # Watches Faye for connect and disconnect. Most of it uses messages, but it
    # also relies on low-level events to watch for disconnects.
    class Monitor

      def initialize(bayeux)
        bayeux.bind(:disconnect) do |client_id|
          Reaction.registry.remove client_id
        end
      end

      # Intercepts connection requests and registers client id with channel ids.
      # Intercepts disconnect requests and unregisters client id.
      def incoming(message, callback)

        # Let non-connect and non-disconnect messages through.
        unless is_connection? message
          return callback.call(message)
        end

        unless message.include? 'channelId' and message.include? 'clientId'
          message['error'] = Faye::Error.channel_forbidden
          return callback.call(message)
        end

        client = message['clientId']
        channel = message['channelId'] # app-assigned channel ID

        # Tell registry that we have received a new client (or lost a client)
        # for that channel. Note that `channel_id` is the ID of the user's
        # channel assigned by the application; the Bayeux channel here is
        # always either `/meta/connect` or `/meta/disconnect`.
        case message['channel']
        when '/meta/connect'
          Reaction.registry.add(channel, client)
        when '/meta/disconnect'
          Reaction.registry.remove client
        end

        callback.call(message)
        # TODO: functional tests

      end

      private

      # @return [Boolean] true iff the message is a connection/disconnection
      #                   request from outside the process.
      def is_connection? message
        ['/meta/connect', '/meta/disconnect'].include? message['channel'] and
        'in-process' != message['connectionType']
        # FIXME: this will change once we separate reaction and rails
      end

    end

  end

end
