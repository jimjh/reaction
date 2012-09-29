module Reaction

  # Registry.
  # Maintains a register of active channels. Internally, it keeps a hash that
  # maps channel IDs to a set of client IDs. When the last client is
  # disconnected, the channel is deleted.
  # --
  # TODO: move this to Redis
  class Registry

    # Creates a new registry.
    def initialize
      @channels = {} # channel_id -> array of client ids
      @lock = Mutex.new
    end

    # Registers a new client for that channel. No op if client is already
    # registered.
    # @param [String] channel ID
    # @param [String] client ID
    def add(channel, client)
      @lock.synchronize do
        @channels[channel] ||= Set.new
        @channels[channel] << client
      end
    end

    # Unregisters the given client from a channel. If it is the last client,
    # removes the channel.
    # @param [String] channel ID
    # @param [String] client ID
    def remove(channel, client)
      @lock.synchronize do
        next unless @channels.include? channel
        @channels[channel].reject! { |c| c == client }
        @channels.delete(channel) if @channels[channel].empty?
      end
    end

    # Iterates through an array of channel IDs.
    def each(&block)
      return @channels.keys.each(&block)
    end

  end

end
