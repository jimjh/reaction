module Reaction

  # Pub/Sub client.
  class Client

    BROADCAST = '/__broadcast_'

    # Creates a new reaction client.
    # @param [Faye::Client] client    bayeux client
    # @param [String]       key       key for {Signer}
    def initialize(client, key)
      @faye = client
      @faye.add_extension Signer.new(key)
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

      @faye.publish BROADCAST, Marshal.dump(encap)

    end

  end

end
