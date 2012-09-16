# Adapted from
# https://github.com/jamesotron/faye-rails/blob/master/lib/faye-rails/routing_hooks.rb

require 'reaction'

# Monkey-patched ActionDispatch router.
module ActionDispatch::Routing

  # Monkey-patched ActionDispatch mapper.
  class Mapper

    # Mounts reaction server.
    # @example Mapping +'/reaction'+ to the reaction server.
    #   mount_reaction :at => '/reaction', :server => 'thin'
    # @option opts [String] :at     where to mount reaction server; defaults to +'/reaction'
    # @option opts [String] :server which server to use; defaults to +'thin'+
    # Other Faye options (e.g. +timeout+) except +:mount+ may also be passed.
    # @raise [RuntimeError] if the server has already been mounted.
    # @return [void]
    def mount_reaction(opts = {})

      raise RuntimeError, 'Reaction already mounted.' if Reaction.bayeux

      opts = defaultize opts
      path = opts.delete :at
      server = opts.delete :server

      Faye::WebSocket.load_adapter server
      # FIXME: is an in-memory registry suitable?
      Reaction.registry = Reaction::Registry.new
      Reaction.bayeux = Reaction::Adapters::RackAdapter.new(opts)

      mount Reaction.bayeux, at: path

    end

    private

    # Populates opts for reaction server with defaults.
    # @param [Hash] opts          hash of options
    # @return [Hash] defaultized options
    def defaultize(opts)
      defaults = {
        at: '/reaction',
        server: 'thin',
        extensions: [Reaction::Registry::Monitor.new]
      }
      opts = defaults.merge opts
      opts[:mount] = '/bayeux' # force!
      opts
    end

  end
end
