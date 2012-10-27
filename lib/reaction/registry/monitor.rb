module Reaction

  # Registry
  class Registry

    # Watches Faye for connect and disconnect. Most of it uses messages, but it
    # also relies on low-level events to watch for disconnects.
    class Monitor
      include Mixins::Logging

      # Token expires after 15 minutes.
      EXPIRY = 15 * 60

      # Creates a new monitor.
      # @param          bayeux  Bayuex server
      # @param [String] salt    Rails secret token
      def initialize(bayeux, salt)
        bayeux.bind(:disconnect) do |client_id|
          Reaction.registry.remove client_id
        end
        @salt = salt
      end

      # Intercepts subscribe requests and registers client id with channel ids.
      def incoming(message, callback)

        case message['channel']
        when '/meta/subscribe'
          channel = Pathname.new(message['subscription']).basename.to_s
          return callback.call(error message) unless is_authorized? message, channel
          Reaction.registry.add(channel, message['clientId'])
        when %r{^/meta/}
        else
          unless is_server?(message)
            warn { "Message #{message} denied." }
            return callback.call(error message)
          end
        end

        callback.call(message)

      end

      private

      # @return [Boolean] true iff the message contains a valid signature.
      def is_server?(message)
        return false unless message.key?('ext') and message['ext'].key?('signature')
        expected = Base64.encode64(OpenSSL::HMAC.digest('sha256', @salt, message['data']))
        expected == message['ext']['signature']
      end

      # Checks the access token against
      #       SHA256(channel_id + date + user-agent + csrf + salt)
      #
      # If the current time is more than {EXPIRY} after the given timestamp,
      # returns false.
      # @param [Hash]    message
      # @param [String]  channel ID
      # @return [Boolean] true iff the message is authorized.
      def is_authorized?(message, channel)
        has_auth? message and
          has_auth_keys? message and
          has_fresh_token? message and
          has_valid_token? message, channel
      end

      # @return [Boolean] true iff message contains 'ext' and 'auth'
      def has_auth?(message)
        message.key? 'ext' and message['ext'].key? 'auth'
      end

      # @return [Boolean] true iff message contains 'auth' and the auth tokens
      def has_auth_keys?(message)
        ext = message['ext']
        components = ['date', 'user_agent', 'csrf', 'token']
        ext.key?('auth') and components.reduce(true) { |b, k| b && ext['auth'].key?(k) }
      end

      # @return [Boolean] true iff message has an unexpired token
      def has_fresh_token?(message)
        auth = message['ext']['auth']
        date = auth['date'].to_i
        (Time.now.to_i - date) <= EXPIRY
      end

      # @return [Boolean] true iff message has a valid token
      def has_valid_token?(message, channel)
        auth = message['ext']['auth']
        expected = Auth.generate_token \
          channel_id: channel,
          date: auth['date'],
          user_agent: auth['user_agent'],
          csrf: auth['csrf'],
          salt: @salt
        expected == auth['token']
      end

      # Adds a 'forbidden' error to the message.
      # @return [Hash] message
      def error(message)
        message['error'] = Faye::Error.channel_forbidden; message
      end

    end

  end

end
