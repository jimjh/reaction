module Reaction

  # Pub/Sub client.
  class Client
    include Mixins::Logging

    BROADCAST = '/__broadcast_'

    # Creates a new reaction client.
    # @param [Faye::Client] client    bayeux client
    # @param [String]       key       secret token
    # FIXME: this code is messy - why do we have the secret token at so many
    # different places?
    def initialize(client, key)
      @faye = client
      @key = key
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
        @faye.publish BROADCAST, Marshal.dump(encap)
      }

    end

    def access_token(opts)
      Registry::Auth.generate_token({salt: @key}.merge opts)
    end

  end

end
