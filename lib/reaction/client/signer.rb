module Reaction

    # Faye extension that adds a message signature to every broadcast message.
    class Client::Signer

      # Initializes the signer with a secret key.
      # @param [String] key        secret key
      def initialize(key)
        @key = key
      end

      # Adds a signature to every outgoing publish message.
      def outgoing(message, callback)

        # Allow non-data messages to pass through.
        unless not message['channel'].start_with?('/meta/') and message.key?('data')
          return callback.call(message)
        end

        message['ext'] ||= {}
        signature = OpenSSL::HMAC.digest('sha256', @key, message['data'])
        message['ext']['signature'] = Base64.encode64(signature)

        callback.call(message)

      end

    end

end
