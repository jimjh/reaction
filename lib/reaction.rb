require 'set'
require 'faye'
require 'openssl'
require 'logger'
require 'reaction/version'

module Reaction

  class << self

    # @!attribute [rw] client
    #   @return bayeux client
    attr_accessor :client

    # @!attribute [rw] registry
    #   @return [Reaction::Registry] registry of connected clients.
    attr_accessor :registry

    # @!attribute [r] paths
    #   @return [Paths] struct containing some convenience paths.
    attr_reader :paths

    # @!attribute [r] logger
    #   @return [Logger] logger
    attr_reader :logger

    # Loads package files.
    # Usage:
    #   require_package :deps
    # loads deps/require.rb, which loads everything else.
    # @param [Symbol] package         name of package to load
    # @return [Boolean] true if loaded, false otherwise
    def require_package(package)
      reqs = File.join('reaction', package.to_s, 'require.rb')
      require_relative reqs
    end

    # @return [Boolean] true if loaded by Rails, false otherwise
    def in_rails?
      const_defined? :Rails and Rails.const_defined? :ActionDispatch
    end

    # Initializes and returns a new paths struct.
    # @return [Struct] struct containing paths.
    def initialize_paths
      paths = Struct.new(:root).new
      paths.root = File.dirname(__FILE__)
      paths
    end

  end

  require_package :mixins

  @paths = initialize_paths
  @logger = Mixins::Logging.new_logger

  require_package :adapters
  require_package :registry
  require_package :rails if in_rails?


end
