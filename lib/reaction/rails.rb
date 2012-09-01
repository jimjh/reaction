# Adapted from
# https://github.com/jamesotron/faye-rails/blob/master/lib/faye-rails/routing_hooks.rb

require 'reaction'

# Monkey-patched ActionDispatch router.
module ActionDispatch::Routing

  # Monkey-patched ActionDispatch mapper.
  class Mapper

    # Mounts reaction server.
    # Usage:
    #   mount_reaction :at => '/reaction', :server => 'thin'
    # = Options
    # * +:at+     - where to mount reaction server, defaults to +'/reaction'+
    # * +:server+ - what server to use, defaults to +'thin'+
    # plus all other Faye options (e.g. +timeout+), except +:mount+.
    def mount_reaction(opts = {})

      raise RuntimeError, 'Reaction already mounted.' if Reaction.bayeux

      opts = prepare_reaction opts
      path = opts.delete :at
      server = opts.delete :server

      Faye::WebSocket.load_adapter server
      Reaction.bayeux = Reaction::RackAdapter.new(opts)
      mount Reaction.bayeux, at: path

    end

    private

    # Populates opts for reaction server with defaults.
    # @param [Hash] opts          hash of options
    # @return [Hash] defaultized options
    def prepare_reaction(opts)
      defaults = {at: '/reaction', server: 'thin'}
      opts = defaults.merge opts
      opts[:mount] = '/bayeux' # force!
      opts
    end

  end
end
