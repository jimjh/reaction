require 'spec_helper'
require 'dummy-rails/spec/spec_helper'

shared_context 'rails app' do

  after(:each) { Reaction.bayeux = nil }

  def app
    DummyRails::Application
  end

  def mount_reaction(*args)
    DummyRails::Application.routes.draw do
      mount_reaction(*args)
    end
  end

end
