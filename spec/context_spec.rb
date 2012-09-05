require 'spec_helper'

describe 'Context' do

  include_context 'reactive context'

  it 'should invoke callbacks when invalidated' do
    dummy = double('block')
    dummy.should_receive(:x)
    Reaction::Context.new
      .on_invalidate { dummy.x }
      .invalidate
    wait
  end

  it 'should work this way' do

    class X

      extend Reaction::Modifiers

      def publish(x)
      end
      reactive :publish

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

    dummy = double('block')
    dummy.should_receive(:x).twice

    x = X.new
    x.publish { dummy.x; x.get(:q) }

    x.set(:q)
    x.set(:p)
    wait

    x.set(:q)
    wait

  end

end
