require 'spec_helper'

describe 'Context' do

  def wait
    thread = Reaction::Context.instance_variable_get('@flushing')
    context = Reaction::Context.new
    context.on_invalidate { Reaction::Context.send :stop_flushing! }
    context.invalidate
    thread.join
    Reaction::Context.send :start_flushing!
  end

  it 'should invoke callbacks when invalidated' do

    block = double('block')
    block.should_receive(:call)

    context = Reaction::Context.new
    context.on_invalidate { block.call }
    context.invalidate

    wait

  end

  it 'should work this way' do

    class X

      def publish(&block)
        Reaction::Context.new
          .on_invalidate { publish(&block) }
          .run(&block)
      end

      def get(key)
        # invalidating and reactive function
        @deps ||= {}
        @deps[key] ||= {}
        c = Reaction::Context.new
        g = Reaction::Context.current
        @deps[key][c.object_id] = c
        id = c.object_id
        c.on_invalidate { g.invalidate; @deps[key].delete(id) }
      end

      def set(key)
        # invalidating function
        return unless @deps && @deps[key]
        contexts = @deps[key]
        contexts.each_value(&:invalidate)
      end

    end

    x = X.new
    x.publish { puts 'here!'; x.get(:q) }

    x.set(:q)
    x.set(:p)
    x.set(:q)

    wait

  end

end
