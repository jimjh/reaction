module Reaction

  # Adapters
  module Adapters

    # Adapter for Rack-based applications.
    class RackAdapter < Faye::RackAdapter

      # @!attribute [rw] registry
      #   @return [Reaction::Registry] registry of connected clients.
      attr_reader :registry

      # @param [Hash] opts      usual Faye options + :key
      def initialize(opts)
        key = opts.delete(:key)
        super opts
        monitor with: key
        sign with: key
      end

      private

      # Adds {Registry::Monitor} extension to faye server.
      # @option opts [String] :key        secret token
      def monitor(opts)
        @registry = Registry.new
        monitor = Registry::Monitor.new self, opts[:with]
        add_extension monitor
      end

      # Adds {Client::Signer} extension to faye client.
      # @option opts [String] :key        secret token
      def sign(opts)
        signer = Client::Signer.new opts[:with]
        get_client.add_extension signer
      end

    end

  end

end
