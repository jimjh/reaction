require 'spec_helper.rb'

describe 'Monitor' do

  RSpec::Matchers.define :forbidden do
    match do |arg|
      arg.kind_of? Hash and arg.key? 'error' and arg['error'] = '403::Forbidden channel'
    end
  end

  Auth = Reaction::Registry::Auth

  context 'given a bayeux server and a random salt' do

    before :each do
      @salt = SecureRandom.uuid
      @reaction = Reaction::Adapters::RackAdapter.new :mount => '/faye',
        :timeout => 25,
        :key => @salt
      @monitor = Reaction::Registry::Monitor.new @reaction, @salt
    end

    def subscribe(channel, auth=nil)
      base = {'channel' => '/meta/subscribe', 'subscription' => channel}
      return base if auth.nil?
      base['ext'] = {'auth' => auth}
      base
    end

    def publish(channel, data)
      return {'channel' => channel, 'clientId' => 0, 'data' => data}
    end

    def authorized(channel, opts={})
      components = {
        channel_id: channel,
        date: Time.now.to_i.to_s,
        user_agent: 'rspec',
        csrf: SecureRandom.hex,
        salt: @salt
      }.merge(opts)
      token = Auth.generate_token components
      auth = components
        .merge(:token => token)
        .reject { |k| [:channel_id, :salt].include? k }
        .inject({}){ |memo, (k,v)| memo[k.to_s] = v; memo }
      return auth
    end

    # Testing with EM is inconvenient, so I am going to test Monitor directly.

    it 'should intercept subscribe messages' do
      callback = double('Proc')
      callback.should_receive(:call).once.with(forbidden)
      @monitor.incoming subscribe('xyz'), callback
    end

    it 'should not intercept non-subscribe messages' do
      message = {'channel' => '/meta/connect'}
      callback = double('Proc')
      callback.should_receive(:call).once.with(message.clone.freeze)
      @monitor.incoming message, callback
    end

    it 'should register authorized subscriptions' do

      channel = 'xyz'
      message = subscribe channel, authorized(channel)

      callback = double('Proc')
      callback.should_receive(:call).once.with(message.clone.freeze)
      @monitor.incoming message, callback

      @reaction.registry.should include(channel)

    end

    it 'should deny subscriptions that are missing any auth components' do

      channel = 'xyz'
      auth = authorized channel

      auth.keys.each { |key|

        bad_auth = auth.reject { |k| k == key }
        message = subscribe(channel, bad_auth)

        callback = double('Proc')
        callback.should_receive(:call).once.with(forbidden)

        @monitor.incoming message, callback

      }

      message = subscribe(channel, auth)
      callback = double('Proc')
      callback.should_receive(:call).once.with(message.clone.freeze)

      @monitor.incoming message, callback

    end

    it 'should deny subscriptions with tokens that have expired' do

      channel = 'xyz'
      auth = authorized channel, date: 16.minutes.ago.to_i.to_s

      message = subscribe(channel, auth)
      callback = double('Proc')
      callback.should_receive(:call).once.with(forbidden)
      @monitor.incoming message, callback

      auth = authorized channel, date: 14.minutes.ago.to_i.to_s
      message['ext']['auth'] = auth

      callback = double('Proc')
      callback.should_receive(:call).once.with(message.clone.freeze)
      @monitor.incoming message, callback

    end

    it 'should deny publish messages without signatures' do

      channel = 'xyz'
      message = publish channel, :hello => 'world'
      callback = double('Proc')
      callback.should_receive(:call).once.with(forbidden)
      @monitor.incoming message, callback

    end

    it 'should deny publish messages with invalid signatures' do

      channel = 'xyz'
      data = {:hello => 'world'}.to_json
      message = publish channel, data

      callback = double('Proc')
      callback.should_receive(:call).once.with(hash_including('data' => data))
      Reaction::Client::Signer.new(@salt).outgoing(message, callback)

      callback = double('Proc')
      callback.should_receive(:call).once.with(message.clone.freeze)
      @monitor.incoming message, callback

    end

    it 'should allow publish messages with valid signatures' do

      channel = 'xyz'
      data = {:hello => 'world'}.to_json
      message = publish channel, data

      callback = double('Proc')
      callback.should_receive(:call).once.with(hash_including('data' => data))
      Reaction::Client::Signer.new(@salt).outgoing(message, callback)

      callback = double('Proc')
      callback.should_receive(:call).once.with(message.clone.freeze)
      @monitor.incoming message, callback

    end

  end

end

