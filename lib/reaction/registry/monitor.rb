module Reaction

  class Registry

    # Watches Faye for subscribe and disconnect.
    class Monitor

      # Intercepts incoming subscription requests and registers channel ids.
      def incoming(message, callback)

        # Let non-subscribe messages through
        unless message['channel'] == '/meta/subscribe'
          return callback.call(message)
        end

        unless message.include? 'channel_id'
          message['error'] = 'Invalid subscription.'
          return callback.call(message)
        end

        Reaction.registry << message['channel_id']
        callback.call(message)

      end

    end

  end

end
