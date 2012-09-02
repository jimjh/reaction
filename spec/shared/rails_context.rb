require 'spec_helper'
require 'dummy-rails/spec/spec_helper'

shared_context 'rails app' do

  def app
    DummyRails::Application
  end

end
