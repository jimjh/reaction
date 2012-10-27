require 'spec_helper'

describe 'Rails app' do

  include_context 'rails app'
  include_context 'rack app'

  @data = [{a: '1', b: '2'}, {a: '2', b: '3'}]

  shared_examples "a published, reactive app" do

    before(:each) do
      k = controller
      DummyRails::Application.routes.draw do
        match "/#{k}/index" => "#{k}#index"
      end
    end

    it 'should return data in REACTION mime type if .reaction extension is present' do
      get "/#{controller}/index.reaction"
      last_response.should be_ok
      content_type.should match %r{^application/vnd\.reaction\.v1}
      body.should match @data.to_json
    end

    it 'should return data in REACTION mime type if Accepts header is present' do
      get "/#{controller}/index.reaction", {}, {'HTTP_ACCEPT' => 'application/vnd.reaction.v1'}
      last_response.should be_ok
      content_type.should match %r{^application/vnd\.reaction\.v1}
      body.should match @data.to_json
    end

  end

  context 'publishing an array of items with respond_with' do
    let(:controller) { 'default' }
    it_behaves_like "a published, reactive app"
  end

  context 'publishing an array of items with respond_to' do

    class YController < ApplicationController
      include Reaction::Rails::Publisher
      def index
        respond_to do |format|
          format.reaction { render :reaction => @data }
        end
      end
    end

    let(:controller) { 'y' }
    it_behaves_like "a published, reactive app"

  end

  context 'publishing an array of items with react_to' do

    class ZController < ApplicationController
      include Reaction::Rails::Publisher
      def index
        react_with(@data) and return if reaction?
      end
    end

    let(:controller) { 'z' }
    it_behaves_like "a published, reactive app"

  end

  shared_examples 'a published, authenticated app' do

    before(:each) do
      k = controller
      DummyRails::Application.routes.draw do
        match "/#{k}/index" => "#{k}#index"
      end
    end

    it 'should generate an appropriate channel ID' do
      get "/#{controller}/index.reaction"
      last_response.should be_ok
      last_response.headers.should include('X-Reaction-Channel')
      last_response.headers['X-Reaction-Channel'].should_not be_empty
      last_response.headers['X-Reaction-Channel'].should match(expected_channel)
    end

    it 'should generate a appropriate access token' do
      get "/#{controller}/index.reaction"
      last_response.should be_ok
      last_response.headers.should include('X-Reaction-Token')
      last_response.headers['X-Reaction-Token'].should_not be_empty
      last_response.headers.should include('Date')
      last_response.headers['Date'].should_not be_empty
    end

    it 'should allow user to authenticate using the given access token' do

      csrf = SecureRandom.hex
      user_agent = SecureRandom.uuid
      get "/#{controller}/index.reaction", {},
        'HTTP_X_CSRF_TOKEN' => csrf,
        'HTTP_USER_AGENT' => user_agent

      date = last_response.headers['Date']
      channel = last_response.headers['X-Reaction-Channel']
      actual_token = last_response.headers['X-Reaction-Token']

      expected_token = Reaction::Registry::Auth.generate_token \
        channel_id: channel,
        date: date,
        user_agent: user_agent,
        csrf: csrf,
        salt: ::Rails.application.config.secret_token

      actual_token.should eq(expected_token)

    end

  end

  context 'generating a channel ID with :reaction_channel' do

    class ReactionChannelController < ApplicationController
      include Reaction::Rails::Publisher
      ID = SecureRandom.uuid

      def index
        respond_with @data
      end

      def reaction_channel
        return ID
      end

    end

    let(:controller) { 'reaction_channel' }
    let(:expected_channel) { ReactionChannelController.const_get(:ID) }
    it_should_behave_like 'a published, authenticated app'

  end

  context 'generating a channel ID with :current_user' do

    class CurrentUserController < ApplicationController
      include Reaction::Rails::Publisher
      ID = SecureRandom.uuid

      def index
        respond_with @data
      end

      def current_user
        Struct.new(:id).new(ID)
      end

    end

    let(:controller) { 'current_user' }
    let(:expected_channel) { CurrentUserController.const_get(:ID) }
    it_should_behave_like 'a published, authenticated app'

  end

  context 'generating a channel ID with Registry::Auth' do
    let(:controller) { 'default' }
    let(:expected_channel) { /.*/ }
    it_should_behave_like 'a published, authenticated app'
  end

  context 'filtering broadcasts' do

    let(:delta) { Struct.new(:attributes) }

    before(:each) do
      @ctrl = DefaultController.new
      @ctrl.params = {origin: 'x'}
    end

    it 'should broadcast a single action' do

      data = [1, 2, 3]

      Reaction.client = double('client')
      Reaction.client.should_receive(:publish).once.with 'default',
        '{"type":"data","items":%s,"action":"create","origin":"x"}' % data.to_json,
        to: /.*/, except: []
      @ctrl.broadcast create: delta.new(data)

    end

    it 'should broadcast all actions' do

      Reaction.client = double('client')

      data1 = [1, 2, 3]
      Reaction.client.should_receive(:publish).once.with 'default',
        '{"type":"data","items":%s,"action":"create","origin":"x"}' % data1.to_json,
        to: /.*/, except: []

      data2 = ['x', 'y', 'z']
      Reaction.client.should_receive(:publish).once.with 'default',
        '{"type":"data","items":%s,"action":"destroy","origin":"x"}' % data2.to_json,
        to: /.*/, except: []

      data3 = {a: 'whatever'}
      Reaction.client.should_receive(:publish).once.with 'default',
        '{"type":"datum","item":%s,"action":"update","origin":"x"}' % data3.to_json,
        to: /.*/, except: []

      @ctrl.broadcast create: delta.new(data1),
                      destroy: delta.new(data2),
                      update: delta.new(data3)

    end

  end

end
