module Reaction

  # TODO
  module Modifiers

    # Makes an unreactive method (that takes a block) respond to invalidating
    # functions in the block.
    def reactive(method)
      unreactive_method = "unreactive_#{method}"
      ensure_undefined unreactive_method.to_sym
      alias_method unreactive_method, method
      define_method method do |*args, &block|
        return_value = Context.new
          .on_invalidate { __send__ method, *args, &block }
          .run(&block)
        __send__ unreactive_method, return_value
      end
    end

    private

    def ensure_undefined(sym)
      raise NameError, sym + 'should be reserved' if method_defined? sym
    end

  end

end
