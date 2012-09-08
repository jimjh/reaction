require 'faye'
require 'reaction/version'

module Reaction

  class << self

    # only one bayeux server per process for now
    attr_accessor :bayeux

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

    # @return [String] path to root of reaction library (points to +lib+).
    def root
      return File.dirname(__FILE__)
    end

  end

  require_package :adapters
  require_package :deps

end
