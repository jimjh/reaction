module Reaction

  # Reaction-Rails
  module Rails

    # Setup path to custom Rails root
    Paths = Struct.new(:root)
    @paths = Paths.new
    @paths.root = File.join(Reaction.root, 'reaction', 'rails')

    class << self
      attr_reader :paths
    end

  end

end

require_relative './rails/mapper'
require_relative './rails/serializer'
require_relative './rails/mime_types'
require_relative './rails/publisher'
