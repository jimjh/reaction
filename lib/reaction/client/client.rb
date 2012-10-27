module Reaction

  # Pub/Sub client.
  class Client

    # Creates a new reaction client.
    # @param [Faye::Client] faye client
    def initialize(faye)
      @faye = faye
    end

    # Publishes message to zero or more channels.
    # @param [String] name    controller name
    # @param [String] message message to send
    # @option opts :to        can be a regular expression or an array, defaults
    #                         to all.
    # @option opts :except    can be a regular expression or an array, defaults
    #                         to none.
    def publish(name, message, opts={})

      to = opts[:to] || /.*/
      except = opts[:except] || []

      Reaction.registry.each { |channel_id|
        next unless accept(to, channel_id) and not accept(except, channel_id)
        channel = "/#{name}/#{channel_id}"
        Reaction.client.publish(channel, delta)
      }

    end

    # Forwards methods to delegate.
    def method_missing(m, *args, &block)
      @faye.send m, *args, &block
    end

    private

    def accept(filter, value)
      case filter
      when Regex
        return filter =~ value
      when Array
        return filter.include? value
      end
      raise RuntimeError, 'Regex or Array expected.'
    end

  end

end
