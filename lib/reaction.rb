require 'faye'
require 'reaction/version'

module Reaction

  # Struct containing some convenience paths for Reaction gem.
  Paths = Struct.new(:root)
  @paths = Paths.new
  @paths.root = File.dirname(__FILE__)

  class << self

    # only one bayeux server per process for now
    attr_accessor :bayeux

    # @!attribute [r] paths
    #   @return [Paths] struct containing some convenience paths.
    attr_reader :paths

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

  end

  require_package :adapters
  require_package :deps

end
