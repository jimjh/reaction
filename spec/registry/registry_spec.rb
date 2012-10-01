require 'spec_helper'

describe 'Registry' do

  let(:reg) { Reaction::Registry.new }

  it 'should create channels if it does not exist' do
    reg.should_not include(0)
    reg.add 0, 'abc'
    reg.should include(0)
  end

  it 'should not create channels if it already exists' do
    reg.add 0, 'abc'
    reg.should include(0)
    reg.add 0, 'def'
    reg.should include(0)
    reg.count.should be 1
  end

  it 'should remove channels if the last client has disconnected' do
    reg.add 0, 'abc'
    reg.add 0, 'def'
    reg.should include(0)
    reg.remove 'def'
    reg.should include(0)
    reg.remove 'abc'
    reg.should_not include(0)
  end

  it 'should ignore bogus clients' do
    reg.add 0, 'abc'
    reg.should include(0)
    reg.remove 'def'
    reg.should include(0)
    reg.remove 'abc'
    reg.should_not include(0)
    reg.remove 'abc'
    reg.should_not include(0)
  end

  it 'should ignore not allow clients to register multiple channels' do
    reg.add 0, 'abc'
    reg.add 1, 'abc'
    reg.count.should be 1
    reg.remove 'abc'
    reg.count.should be 0
  end

  it 'should iterate through list of channels' do

    channels = [0, 1, 'blah']
    channels.each { |channel| reg.add channel, channel }

    reg.each do |channel|
      channels.should include(channel)
      channels.delete channel
    end

    channels.should be_empty

  end

end
