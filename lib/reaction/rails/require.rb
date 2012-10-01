module Reaction

  # Reaction-Rails adapter that contains a suite of tools for using Reaction
  # with Rails.
  module Rails

    # Struct containing some convenience paths for Rails module.
    # @attr [String] root   path to +lib/reaction/rails+
    Paths = Struct.new(:root)
    @paths = Paths.new
    @paths.root = File.join(Reaction.paths.root, 'reaction', 'rails')

    @paths.freeze

    class << self
      # @!attribute [r] paths
      # @return [Paths] struct containing some convenience paths.
      attr_reader :paths
    end

  end

end

glob = File.expand_path('*.rb', File.dirname(__FILE__))
Dir[glob].each { |file| require file }
