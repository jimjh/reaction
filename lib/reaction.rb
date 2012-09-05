require 'faye'

require 'reaction/version'

module Reaction

  class << self

    # only one bayeux server per process for now
    attr_accessor :bayeux

    # Loads package files.
    # Usage:
    #   require_package :deps
    def require_package(package)
      reqs = File.join('reaction', package.to_s, 'require.rb')
      require_relative reqs
    end

  end

  require_package :adapters
  require_package :deps

end
