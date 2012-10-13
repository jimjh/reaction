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

end
