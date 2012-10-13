require 'spec_helper'
require 'dummy-rails/spec/spec_helper'
require 'reaction/rails/require'

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

  class DefaultController < ApplicationController
    include Reaction::Rails::Publisher
    def index
      respond_with @data
    end
  end

end
