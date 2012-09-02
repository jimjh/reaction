require 'spec_helper'

describe 'Rails App' do

  include_context 'rails app'
  include_context 'rack app'

  it 'should start successfully' do
    get '/'
    last_response.should be_ok
    last_response.should match(/You are up!/)
  end

  it "should have a route to faye's client script" do
    get '/reaction/bayeux/client.js'
    last_response.should be_ok
    content_type.should == 'text/javascript'
  end

end
