require 'faye'

require 'reaction/version'
require 'reaction/adapters/rack_adapter'
require 'reaction/deps/context'
require 'reaction/deps/modifiers'

module Reaction

  class << self
    # only one bayeux server per process for now
    attr_accessor :bayeux
  end

end
