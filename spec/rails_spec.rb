require 'spec_helper'

describe 'Rails App' do

  include_context 'rails app'
  include_context 'rack app'

  it 'should start successfully' do
    mount_reaction at: '/r'
    get '/'
    last_response.should be_ok
    last_response.should match(/You are up!/)
  end

  it "should have a route to faye's client script" do
    mount_reaction at: '/r'
    get '/r/bayeux/client.js'
    last_response.should be_ok
    content_type.should == 'text/javascript'
  end

  it 'should not allow reaction to be mounted twice' do
    mount_reaction at: '/reaction'
    lambda { mount_reaction }.should raise_error(RuntimeError)
  end

  it 'should not allow user to change faye mount point' do
    mount_reaction at: '/r', mount: '/b'
    get '/r/b/client.js'
    last_response.should be_not_found
    get '/r/bayeux/client.js'
    last_response.should be_ok
  end

end
