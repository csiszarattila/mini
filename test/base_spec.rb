require File.dirname(__FILE__) + '/test_helper'

describe 'Mini' do
  it 'should have default page' do
    get '/'
    @response.should be_ok
  end
end