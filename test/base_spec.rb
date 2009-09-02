require 'sinatra'
require 'sinatra/test/rspec'
require File.dirname(__FILE__) + '/../mini'

describe 'Mini' do
  it 'should have default page' do
    get '/'
    @response.should be_ok
    @response.body.should equal('ok') 
  end
end