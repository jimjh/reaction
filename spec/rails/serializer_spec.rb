require 'spec_helper'

describe 'Serializer' do

  context 'given some arbitrary models' do

    Person = Struct.new :name, :updated_at

    before :each do
      @names = ['Adrian', 'Audrey', 'Jerene', 'X', 'Inez', 'John']
      @people = @names.map { |name| Person.new name, Time.now }
    end

    it 'should format array as data' do

      json = Reaction::Rails::Serializer.format_data @people
      hash = JSON.parse json

      hash['type'].should eql 'data'
      hash['items'].should_not be_nil
      hash['items'].each { |item|
        @names.should include(item['name'])
        @names.delete item['name']
      }

      @names.should be_empty

    end

    it 'should format object as datum' do

      @person = Person.new 'batman'
      json = Reaction::Rails::Serializer.format_data @person
      hash = JSON.parse json

      hash['type'].should eql 'datum'
      hash['item'].should_not be_nil
      hash['item']['name'].should eql @person.name

    end

    it 'should handle null objects' do
      expected = {type: 'datum', item: nil}.to_json
      Reaction::Rails::Serializer.format_data(nil).should eql(expected)
    end

    it 'should accept custom fields' do

      json = Reaction::Rails::Serializer.format_data @people, action: 'x'
      hash = JSON.parse json
      hash['action'].should eql 'x'

      @person = Person.new 'xman'
      json = Reaction::Rails::Serializer.format_data @person, action: 'y'
      hash = JSON.parse json
      hash['action'].should eql 'y'

    end

    it 'should add errors if any' do

      @person = {name: 'batman'}
      def @person.errors
        return ['xyz']
      end

      json = Reaction::Rails::Serializer.format_data @person
      hash = JSON.parse json
      hash['errors'].should eql @person.errors

    end

    it 'should handle frozen objects' do

      @person = Person.new 'batman'
      @person.freeze

      json = Reaction::Rails::Serializer.format_data @person
      hash = JSON.parse json
      hash['item']['name'].should eql @person.name

    end

    it 'should convert updated_at to float' do

      @person = Person.new 'batman', Time.now

      json = Reaction::Rails::Serializer.format_data @person
      hash = JSON.parse json

      hash['item']['updated_at'].should eql @person.updated_at

    end

  end

  context 'given an array of models and a sync request' do

    Car = Struct.new :id, :name, :updated_at

    before(:each) do
      @cars = [ Car.new(256, 'X', Time.now),
                Car.new(111, 'Y', Time.now)]
    end

    it 'should format the diff containing new cars' do

      json = Reaction::Rails::Serializer.format_diff @cars, {}
      deltas = JSON.parse(json)['deltas']

      deltas.size.should be(2)
      deltas.each do |d|
        d.should include('action')
        d['action'].should eq('create')
        d.should include('item')
        @cars.delete_if { |c| c.id == d['item']['id'] }
      end
      @cars.size.should be(0)

    end

    it 'should format the diff containing deleted persons' do

      cached = { '5' => 1.day.ago.to_i }

      json = Reaction::Rails::Serializer.format_diff @cars, cached: cached
      deltas = JSON.parse(json)['deltas']

      deltas.size.should be(3)
      deltas.any? do |d|
        d.include? 'action' and
        d['action'] == 'destroy' and
        d.include? 'item' and
        d['item']['id'].to_i == 5
      end.should be(true)

    end

    it 'should format the diff containing updated persons' do

      cached = { '111' => 1.day.ago.to_i }

      json = Reaction::Rails::Serializer.format_diff @cars, cached: cached
      deltas = JSON.parse(json)['deltas']

      deltas.size.should be(2)
      deltas.any? do |d|
        d.include? 'action' and
        d['action'] == 'update' and
        d.include? 'item' and
        d['item']['id'].to_i == 111
      end.should be(true)

    end

  end

end
