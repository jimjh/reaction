module Reaction

  # Adapters
  module Adapters

    # Adapter for Rack-based applications. Currently supports starting a reaction
    # server in-process.
    # --
    # TODO: support starting external reaction servers.
    # TODO: save registry in redis
    class RackAdapter < Faye::RackAdapter

      def call(env)

        request = Rack::Request.new(env)
        return super unless request.path_info == '/heartbeat'

        Reaction.registry << request.cookies["channel_id"]
        [200, {}, []]

      end

    end

  end

end
