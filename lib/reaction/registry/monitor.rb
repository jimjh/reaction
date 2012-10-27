module Reaction

  # Registry
  class Registry

    # Watches Faye for connect and disconnect. Most of it uses msgs, but it
    # also relies on low-level events to watch for disconnects.
    class Monitor
      include Mixins::Logging

      # Token expires after 15 minutes.
      EXPIRY = 15 * 60

      # Creates a new monitor.
      # @param          reaction  bayuex server
      # @param [String] salt      secret token
      def initialize(reaction, salt)

        reaction.bind(:disconnect) do |client_id|
          reaction.registry.remove client_id
        end

        @reaction = reaction
        @salt = salt

      end

      # Intercepts subscribe requests and registers client id with channel ids.
      def incoming(msg, cb)

        case msg['channel']
        when '/meta/subscribe'
          channel = Pathname.new(msg['subscription']).basename.to_s
          return deny(msg, cb) unless is_authorized? msg, channel
          @reaction.registry.add(channel, msg['clientId'])
        when %r{^/meta/}
        else
          return app_push msg, cb
        end

        cb.call(msg)

      end

      private

      # Handles pushes from the application.
      # - Checks if the msg has a valid signature.
      # - Checks if the msg is a broadcast request.
      # @return [void]
      def app_push(msg, cb)
        return deny(msg, cb) unless is_application?(msg)
        return broadcast(msg, cb) if Client::BROADCAST == msg['channel']
        cb.call(msg)
      end

      # Broadcasts the msg to multiple clients.
      # @return [void]
      def broadcast(msg, cb)

        # de-encapsulate
        encap = Marshal.load msg['data']
        name, msg, to, except = encap[:n], encap[:m], encap[:t], encap[:e]

        reaction.registry.each { |channel_id|
          next unless accept(to, channel_id) and not accept(except, channel_id)
          channel = "/#{name}/#{channel_id}"
          @reaction.get_client.publish(channel, msg)
          # FIXME: these will get denied
        }

      end

      # Verifies that the given msg is from the application.
      # @return [Boolean] true iff the msg contains a valid signature.
      def is_application?(msg)
        return false unless msg.key?('ext') and msg['ext'].key?('signature')
        expected = Base64.encode64(OpenSSL::HMAC.digest('sha256', @salt, msg['data']))
        expected == msg['ext']['signature']
      end

      # Checks the access token against
      #       SHA256(channel_id + date + user-agent + csrf + salt)
      #
      # If the current time is more than {EXPIRY} after the given timestamp,
      # returns false.
      # @param [Hash]    msg
      # @param [String]  channel ID
      # @return [Boolean] true iff the msg is authorized.
      def is_authorized?(msg, channel)
        has_auth? msg and
          has_auth_keys? msg and
          has_fresh_token? msg and
          has_valid_token? msg, channel
      end

      # @return [Boolean] true iff msg contains 'ext' and 'auth'
      def has_auth?(msg)
        msg.key? 'ext' and msg['ext'].key? 'auth'
      end
      # @return [Boolean] true iff msg contains 'auth' and the auth tokens
      def has_auth_keys?(msg)
        ext = msg['ext']
        components = ['date', 'user_agent', 'csrf', 'token']
        ext.key?('auth') and components.reduce(true) { |b, k| b && ext['auth'].key?(k) }
      end

      # @return [Boolean] true iff msg has an unexpired token
      def has_fresh_token?(msg)
        auth = msg['ext']['auth']
        date = auth['date'].to_i
        (Time.now.to_i - date) <= EXPIRY
      end

      # @return [Boolean] true iff msg has a valid token
      def has_valid_token?(msg, channel)
        auth = msg['ext']['auth']
        expected = Auth.generate_token \
          channel_id: channel,
          date: auth['date'],
          user_agent: auth['user_agent'],
          csrf: auth['csrf'],
          salt: @salt
        expected == auth['token']
      end

      # Adds a 'forbidden' error to the msg.
      # @return [void]
      def deny(msg, cb)
        warn { "msg #{msg} denied." }
        msg['error'] = Faye::Error.channel_forbidden
        return cb.call(msg)
      end

      # @param [Regexp|Array]   filter
      # @param [String|Object]  value
      # @raise RuntimeError if filter is neither Regexp nor Array.
      # @return [Boolean] true iff given filter accepts value.
      def accept(filter, value)
        case filter
        when Regexp
          return filter =~ value
        when Array
          return filter.include? value
        end
        raise RuntimeError, 'Regex or Array expected.'
      end

    end

  end

end
