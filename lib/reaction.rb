require 'faye'

require 'reaction/adapters/rack_adapter'
require 'reaction/version'

module Reaction

  class << self
    # only one bayeux server per process for now
    attr_accessor :bayeux
  end

end
