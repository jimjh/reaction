module Reaction

  # Pub/Sub client.
  class Client
    include Mixins::Logging

    # Channel for broadcasting messages
    BROADCAST = '/__broadcast_'

    # Creates a new reaction client.
    # @param [Faye::Client] client    bayeux client
    # @param [String]       salt      secret salt, used to generate access
    #                                 tokens
    def initialize(client, salt)
      @faye = client
      @salt = salt
    end

    # Publishes message to zero or more channels.
    # @param [String] name    controller name
    # @param [String] message message to send
    # @option opts :to        can be a regular expression or an array, defaults
    #                         to all.
    # @option opts :except    can be a regular expression or an array, defaults
    #                         to none.
    def broadcast(name, message, opts={})

      # encapsulation
      encap = { n: name,
                m: message,
                t: opts[:to] || /.*/,
                e: opts[:except] || []
              }

      EM.next_tick {
        @faye.publish BROADCAST, Base64.urlsafe_encode64(Marshal.dump(encap))
      }

    end

    # Generates access tokens that can be passed to the browser client.
    # @param [Hash] opts      hash of data to be included in the token
    # @return [String] access token
    def access_token(opts)
      Registry::Auth.generate_token({salt: @salt}.merge opts)
    end

  end

end
