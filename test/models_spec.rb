require File.dirname(__FILE__) + '/test_helper'

describe 'Models' do
  it "should have Article" do
    lambda{ Article }.should_not raise_error
  end
  
  it "should have Post" do
    lambda{ Post }.should_not raise_error
  end
  
  it "should have Comment" do
    lambda{ Comment }.should_not raise_error
  end
end