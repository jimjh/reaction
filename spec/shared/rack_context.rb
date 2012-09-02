require 'spec_helper'

shared_context 'rack app' do

  include Rack::Test::Methods

  let(:content_type) { last_response.content_type }

end
