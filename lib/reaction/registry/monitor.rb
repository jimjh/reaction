module Reaction

  # --
  # XXX: BAD CODE.
  # * Channel ID is confusing, because we have faye channels, and then reaction's
  #   channel IDs.
  class Registry

    # Watches Faye for connect and disconnect.
    class Monitor

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

        channel = message['channelId']
        client = message['clientId']

        # Tell registry that we have a new client (or lost a client) for that
        # channel.
        case message['channel']
        when '/meta/connect'
          Reaction.registry.add(channel, client)
        when '/meta/disconnect'
          Reaction.registry.remove(channel, client)
        end

        callback.call(message)
        # TODO: functional tests

      end

      private

      def is_connection? message
        ['/meta/connect', '/meta/disconnect'].include? message['channel'] and
        'in-process' != message['connectionType']
        # FIXME: this will change once we separate reaction and rails
      end

    end

  end

end
