module Reaction

  # Reaction-Rails
  module Rails

    # Struct containing some convenience paths for Rails module.
    # @attr_reader [String] path to +lib/reaction/rails+
    Paths = Struct.new(:root)
    @paths = Paths.new
    @paths.root = File.join(Reaction.paths.root, 'reaction', 'rails')

    class << self
      # @!attribute [r] paths
      # @return [Paths] struct containing some convenience paths.
      attr_reader :paths
    end

  end

end

require_relative './rails/mapper'
require_relative './rails/serializer'
require_relative './rails/mime_types'
require_relative './rails/publisher'
