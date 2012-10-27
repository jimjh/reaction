module Reaction

  # Pub/Sub client.
  class Client

    BROADCAST = '/__broadcast_'

    # Creates a new reaction client.
    # @param [Faye::Client] faye client
    def initialize(faye)
      @faye = faye
      @faye.add_extension Signer.new
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

    # Forwards methods to delegate.
    def method_missing(m, *args, &block)
      @faye.public_send m, *args, &block
    end

  end

end
