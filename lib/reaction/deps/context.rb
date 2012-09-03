module Reaction

  # Adapted from https://github.com/meteor/meteor/blob/master/packages/deps/deps.js
  class Context

    # NOTE: class variables are not the same as instance variables of the class
    # object.

    # current context (global)
    @current = nil
    # queue of invalidated contexts
    @invalidated_contexts = Queue.new

    class << self

      attr_accessor :current
      attr_reader :invalidated_contexts

      private

      # Stops flushing and kills the thread.
      def stop_flushing!
        return unless @flushing
        thread = @flushing
        @flushing = nil
        thread.exit
      end

      # Start flushing invalidated contexts.
      def start_flushing!
        return if @flushing
        @flushing = Thread.new { flush! }
      end

      def flush!
        loop do
          context = @invalidated_contexts.pop
          context.invalidate!
        end
      end

    end # class

    start_flushing!

    def initialize
      @callbacks = []
      @invalidated = false
    end

    # Registers a callback that is invoked when context is invalidated.
    # @yield callback
    def on_invalidate(&block)
      raise ArgumentError, 'no block given' unless block_given?
      @invalidated ? block.call : @callbacks << block
      self
    end

    # Sets +invalidated+ to true and schedules callbacks.
    # After callbacks have been invoked, +invalidated+ is returned to false.
    def invalidate
      return if @invalidated
      @invalidated = true
      Context.invalidated_contexts << self
    end

    # Invokes callbacks immediately.
    def invalidate!
      @callbacks.each { |c| c.call }
    end

    # Executes block with this reactive context.
    # @yield block to execute within this reactive context
    def run
      raise ArgumentError, 'block expected' unless block_given?
      previous = Context.current
      Context.current = self
      begin
        result = yield
      ensure
        Context.current = previous
      end
      result
    end

  end # Context

end # Reaction
