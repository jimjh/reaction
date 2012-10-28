module Reaction

    # Faye extension that adds a message signature to every broadcast message.
    class Client::Signer
      include Mixins::Logging

      # Initializes the signer with a secret key.
      # @param [String] key        secret key, used to sign messages
      def initialize(key)
        @key = key
      end

      # Adds a signature to every outgoing publish message.
      def outgoing(message, callback)

        # Allow non-data messages to pass through.
        return callback.call(message) if %r{^/meta/} =~ message['channel']

        message['ext'] ||= {}
        signature = OpenSSL::HMAC.digest('sha256', @key, message['data'])
        message['ext']['signature'] = Base64.encode64(signature)

        return callback.call(message)

      end

    end

end
