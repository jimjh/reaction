require 'spec_helper'

describe 'Auth' do

  it 'should raise an error when options is nil' do
    lambda { Reaction::Registry::Auth.generate_token nil }.should raise_error
  end

  it 'should raise an error when options is incomplete' do

    components = {
      :channel_id => 'x',
      :date => 'y',
      :user_agent => 'z',
      :csrf => 'a',
      :salt => 'b'
    }.freeze

    components.keys.each do |key|
      lambda do
        Reaction::Registry::Auth.generate_token components.reject { |k| k == key }
      end.should raise_error
    end

  end

  it 'should compare a different hash when the options are varied' do

    components = {
      :channel_id => 'x',
      :date => 'y',
      :user_agent => 'z',
      :csrf => 'a',
      :salt => 'b'
    }.freeze

    components.each do |key, value|
      h1 = Reaction::Registry::Auth.generate_token components
      h2 = Reaction::Registry::Auth.generate_token components.merge({key => value + '0'})
      h1.should_not == h2
    end

  end

end
