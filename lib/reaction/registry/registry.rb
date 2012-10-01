module Reaction

  # Registry.
  # Maintains a register of active channels. Internally, it keeps a hash that
  # maps client IDs to channel IDs and their respective counters. When a new
  # client is added, the counter is incremented; when a client is removed, the
  # counter is decremented. When the counter hits zero, the channel is removed.
  # --
  # TODO: move this to Redis
  class Registry

    include Enumerable

    # Creates a new registry.
    def initialize
      @clients = {} # client_id -> channel_id
      @channels = {} # channel_id -> counter
      @lock = Mutex.new
    end

    # Registers a new client for that channel. No op if client is already
    # registered.
    # @param [String] channel ID
    # @param [String] client ID
    def add(channel, client)
      @lock.synchronize do
        next if @clients.key? client
        ::Rails.logger.debug "Adding #{client} to #{channel}."
        @clients[client] = channel
        @channels[channel] = @channels[channel] ? @channels[channel] + 1 : 1
      end
    end

    # Unregisters the given client from a channel. If it is the last client,
    # removes the channel.
    # @param [String] client ID
    def remove(client)
      @lock.synchronize do
        next unless @clients.include? client
        channel = @clients.delete(client)
        ::Rails.logger.debug "Removing #{client} from #{channel}."
        @channels[channel] -= 1
        @channels.delete(channel) if @channels[channel].zero?
      end
    end

    # Iterates through an array of channel IDs.
    def each(&block)
      return @channels.keys.each(&block)
    end

  end

end
