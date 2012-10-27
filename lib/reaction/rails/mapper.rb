# Adapted from
# https://github.com/jamesotron/faye-rails/blob/master/lib/faye-rails/routing_hooks.rb

require 'reaction'

# Monkey-patched ActionDispatch router.
module ActionDispatch::Routing

  # Monkey-patched ActionDispatch mapper.
  class Mapper

    # Uses an external reaction server.
    # @example Using an external reaction server at +localhost:9292/reaction+.
    #   use_reaction :at => 'http://localhost:9292/reaction'
    # @option opts [String] :at     URL of external reaction server.
    # @return [void]
    def use_reaction(opts = {})
      opts = use_reaction_defaults opts
      Reaction.client = Faye::Client.new opts[:at]
    end

    # Mounts reaction server.
    # @example Mapping +'/reaction'+ to the reaction server.
    #   mount_reaction :at => '/reaction', :server => 'thin'
    # @option opts [String] :at     where to mount reaction server; defaults to +'/reaction'
    # @option opts [String] :server which server to use; defaults to +'thin'+
    # Other Faye options (e.g. +timeout+) except +:mount+ may also be passed.
    # @raise [RuntimeError] if the server has already been mounted.
    # @return [void]
    def mount_reaction(opts = {})

      raise RuntimeError, 'Reaction already mounted.' if Reaction.client

      opts = mount_reaction_defaults opts
      path = opts.delete :at
      server = opts.delete :server

      Faye::WebSocket.load_adapter server
      bayeux = Reaction::Adapters::RackAdapter.new(opts)

      Reaction.registry = Reaction::Registry.new
      monitor = Reaction::Registry::Monitor.new \
        bayeux,
        Rails.application.config.secret_token
      bayeux.add_extension monitor

      mount bayeux, at: path
      Reaction.client = bayeux.get_client

    end

    private

    # Populates +opts+ for reaction server with defaults.
    # @param [Hash] opts          hash of options
    # @return [Hash] defaultized options
    def use_reaction_defaults(opts)
      defaults = {
        at: 'http://localhost:9292/reaction'
      }
      opts = defaults.merge opts
    end

    # Populates +opts+ for reaction server with defaults.
    # @param [Hash] opts          hash of options
    # @return [Hash] defaultized options
    def mount_reaction_defaults(opts)
      defaults = {
        at: '/reaction',
        server: 'thin'
      }
      opts = defaults.merge opts
      opts.delete :mount
      opts
    end

  end
end
