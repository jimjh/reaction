require 'spec_helper'

describe 'Rails app' do

  include_context 'rails app'
  include_context 'rack app'

  @data = [{a: '1', b: '2'}, {a: '2', b: '3'}]

  shared_examples "a published, reactive app" do

    before(:each) do
      k = klass
      DummyRails::Application.routes.draw do
        match "/#{k}/index" => "#{k}#index"
      end
    end

    it 'should return data in REACTION mime type if .reaction extension is present' do
      get "/#{klass}/index.reaction"
      last_response.should be_ok
      last_response.content_type.should match %r{^application/vnd\.reaction\.v1}
      last_response.body.should match @data.to_json
    end

    it 'should return data in REACTION mime type if Accepts header is present' do
      get "/#{klass}/index.reaction", {}, {'HTTP_ACCEPT' => 'application/vnd.reaction.v1'}
      last_response.should be_ok
      last_response.content_type.should match %r{^application/vnd\.reaction\.v1}
      last_response.body.should match @data.to_json
    end

  end

  context 'publishing an array of items with respond_with' do

    class XController < ApplicationController
      include Reaction::Rails::Publisher
      def index
        respond_with @data
      end
    end

    let(:klass) { 'x' }
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

    let(:klass) { 'y' }
    it_behaves_like "a published, reactive app"

  end

  context 'publishing an array of items with react_to' do

    class ZController < ApplicationController
      include Reaction::Rails::Publisher
      def index
        react_with(@data) and return if reaction?
      end
    end

    let(:klass) { 'z' }
    it_behaves_like "a published, reactive app"

  end

end
