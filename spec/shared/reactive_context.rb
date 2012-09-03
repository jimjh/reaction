require 'spec_helper'

shared_context 'reactive context' do

  # super hacky way to force rspec to wait for thread
  def wait
    thread = Reaction::Context.instance_variable_get('@flushing')
    context = Reaction::Context.new
    context.on_invalidate { Reaction::Context.send :stop_flushing! }
    context.invalidate
    thread.join
    Reaction::Context.send :start_flushing!
  end

end
