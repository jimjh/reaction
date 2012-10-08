require 'spec_helper'

describe 'Integration testing with PhantomJS', :type => :request, :js => true do

  it 'should execute javascript' do
    result = page.evaluate_script('4 + 4');
    result.should == 8
  end

end
