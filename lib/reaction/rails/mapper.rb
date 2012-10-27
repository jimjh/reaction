# Adapted from
# https://github.com/jamesotron/faye-rails/blob/master/lib/faye-rails/routing_hooks.rb

require 'reaction'

# Monkey-patched ActionDispatch router.
module ActionDispatch::Routing

  # Monkey-patched ActionDispatch mapper.
  class Mapper

    # Uses an external reaction server.
    #
    # @example Using an external reaction server at +localhost:9292/reaction+.
    #   use_reaction :at => 'http://localhost:9292/reaction'
    #
    # @option opts [String] :at     URL of external reaction server.
    # @option opts [String] :key    secret token, used for signing messages
    #                               published from app server; defaults to
    #                               +Rails.application.config.secret_token+
    # @raise [RuntimeError] if the reaction client has already been initialized.
    # @return [Reaction::Client] client
    def use_reaction(opts = {})

      raise RuntimeError, 'Already using Reaction.' if Reaction.client

      opts = use_reaction_defaults opts
      faye = Faye::Client.new opts[:at]
      Reaction.client = Reaction::Client.new faye, opts[:key]

    end

    # Mounts reaction server.
    # Other Faye options (e.g. +timeout+) except +:mount+ may also be passed.
    #
    # @example Mapping +'/reaction'+ to the reaction server.
    #   mount_reaction :at => '/reaction', :server => 'thin'
    #
    # @option opts [String] :at     where to mount reaction server; defaults to
    #                               +'/reaction'
    # @option opts [String] :server which server to use; defaults to +'thin'+
    # @option opts [String] :key    secret token, used for signing messages
    #                               published from app server; defaults to
    #                               +Rails.application.config.secret_token+
    #
    # @raise [RuntimeError] if the server has already been mounted.
    # @return [Reaction::Client] client
    def mount_reaction(opts = {})

      raise RuntimeError, 'Reaction already mounted.' if Reaction.client

      opts = mount_reaction_defaults opts
      at, server, key = opts.extract!(:at, :server, :key).values

      Faye::WebSocket.load_adapter server
      bayeux = Reaction::Adapters::RackAdapter.new(opts)

      Reaction.registry = Reaction::Registry.new
      monitor = Reaction::Registry::Monitor.new bayeux, key

      bayeux.add_extension monitor
      mount bayeux, at: at

      Reaction.client = Reaction::Client.new bayeux.get_client, key

    end

    private

    # Populates +opts+ for reaction server with defaults.
    # @param [Hash] opts          hash of options
    # @return [Hash] defaultized options
    def use_reaction_defaults(opts)
      defaults = {
        at: 'http://localhost:9292/reaction',
        key: Rails.application.config.secret_token
      }
      opts = defaults.merge opts
    end

    # Populates +opts+ for reaction server with defaults.
    # @param [Hash] opts          hash of options
    # @return [Hash] defaultized options
    def mount_reaction_defaults(opts)
      defaults = {
        at: '/reaction',
        server: 'thin',
        key: Rails.application.config.secret_token
      }
      opts = defaults.merge opts
      opts.delete :mount
      opts
    end

  end
end
