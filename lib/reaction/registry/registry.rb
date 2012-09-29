module Reaction

  # Registry.
  # Maintains a register of active clients.
  class Registry

    # Number of missed epochs before deciding that a channel is dead.
    EPOCH_LIMIT = 4

    # Number of seconds for each epoch.
    EPOCH_SECONDS = 0.5

    # Creates a new registry.
    def initialize
      @channels = {}
      @lock = Mutex.new
      check
    end

    # Resets epoch count for channel, and adds it to the set if it does not
    # already exists.
    def <<(channel_id)
      @lock.synchronize do
        @channels[channel_id] = 0
      end
    end

    def each(&block)
      return @channels.keys.each(&block)
    end

    private

    # Checks if any of the connections have expired.
    def check

      Thread.new do
        loop do
          @lock.synchronize do
            @channels.each do |id, count|
              @channels[id] += 1
              @channels.delete(id) if count >= EPOCH_LIMIT
            end
          end
          sleep EPOCH_SECONDS
        end
      end

    end

  end

end
